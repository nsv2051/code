#!/bin/bash
# 自动配置时区和 NTP，适用于 Debian/Ubuntu

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "[错误] 请以 root 权限运行此脚本（使用 sudo）"
    exit 1
fi

# 设置时区为 Asia/Shanghai（北京时间）
timedatectl set-timezone Asia/Shanghai || {
    echo "[错误] 设置时区失败"
    exit 1
}

# 安装 Chrony（优先）或 NTP
if ! command -v chronyd >/dev/null 2>&1; then
    echo "[信息] 正在安装 Chrony..."
    apt-get update
    apt-get install -y chrony
    if [ $? -ne 0 ]; then
        echo "[信息] Chrony 安装失败，尝试安装 NTP..."
        apt-get install -y ntp || {
            echo "[错误] 无法安装 Chrony 或 NTP"
            exit 1
        }
    fi
fi

# 配置阿里云 NTP 服务器并设置同步周期
if [ -f /etc/chrony/chrony.conf ]; then
    echo "[信息] 配置 Chrony..."
    sed -i '/^pool\|^server/d' /etc/chrony/chrony.conf
    echo "server ntp.aliyun.com iburst" >> /etc/chrony/chrony.conf
    sed -i '/^maxpoll/d' /etc/chrony/chrony.conf
    echo "maxpoll 17" >> /etc/chrony/chrony.conf
    # 检查是否有其他 NTP 服务冲突
    if systemctl is-active ntp >/dev/null 2>&1; then
        systemctl stop ntp
        systemctl disable ntp
        echo "[信息] 已停止并禁用冲突的 NTP 服务"
    fi
    systemctl restart chronyd || {
        echo "[错误] Chronyd 服务重启失败，请检查 'systemctl status chronyd' 和 'journalctl -xe'"
        exit 1
    }
    systemctl enable chronyd || echo "[警告] 启用 chronyd 服务失败，可能是别名问题，但服务已运行"
elif [ -f /etc/ntp.conf ]; then
    echo "[信息] 配置 NTP..."
    sed -i '/^pool\|^server/d' /etc/ntp.conf
    echo "server ntp.aliyun.com iburst" >> /etc/ntp.conf
    sed -i '/^maxpoll/d' /etc/ntp.conf
    echo "maxpoll 17" >> /etc/ntp.conf
    systemctl restart ntp || {
        echo "[错误] NTP 服务重启失败，请检查 'systemctl status ntp'"
        exit 1
    }
    systemctl enable ntp
fi

# 立即强制同步时间
if command -v chronyc >/dev/null 2>&1; then
    echo "[信息] 正在同步 Chrony 时间..."
    chronyc makestep || {
        echo "[错误] Chrony 时间同步失败，可能是服务未运行"
        systemctl status chronyd
        exit 1
    }
elif command -v ntpdate >/dev/null 2>&1; then
    echo "[信息] 正在同步 NTP 时间..."
    ntpdate ntp.aliyun.com || {
        echo "[错误] NTP 时间同步失败"
        exit 1
    }
fi

# 检查同步是否成功
if [ $? -eq 0 ]; then
    echo "[成功] 时区：Asia/Shanghai | NTP：ntp.aliyun.com | 同步周期：约 24 小时"
else
    echo "[错误] 时间同步失败"
    exit 1
fi
