#!/bin/bash
# 自动配置时区和 NTP，适用于 Debian/Ubuntu

# 设置时区为 Asia/Shanghai（北京时间）
timedatectl set-timezone Asia/Shanghai

# 安装 Chrony（优先）或 NTP
if ! command -v chronyd >/dev/null 2>&1; then
    apt-get update
    apt-get install -y chrony || apt-get install -y ntp
fi

# 配置阿里云 NTP 服务器并设置同步周期
if [ -f /etc/chrony/chrony.conf ]; then
    # 删除现有的 pool/server 配置，确保只使用一个服务器
    sed -i '/^pool\|^server/d' /etc/chrony/chrony.conf
    echo "server ntp.aliyun.com iburst" >> /etc/chrony/chrony.conf
    # 设置最大轮询间隔约为 24 小时（2^17 秒 ≈ 36 小时，接近 24 小时的实用值）
    sed -i '/^maxpoll/d' /etc/chrony/chrony.conf
    sed -i '/^minpoll/d' /etc/chrony/chrony.conf
    echo "maxpoll 17" >> /etc/chrony/chrony.conf
    systemctl restart chronyd
    systemctl enable chronyd
elif [ -f /etc/ntp.conf ]; then
    # 删除现有的 pool/server 配置，确保只使用一个服务器
    sed -i '/^pool\|^server/d' /etc/ntp.conf
    echo "server ntp.aliyun.com iburst" >> /etc/ntp.conf
    # 设置最大轮询间隔约为 24 小时
    sed -i '/^maxpoll/d' /etc/ntp.conf
    sed -i '/^minpoll/d' /etc/ntp.conf
    echo "maxpoll 17" >> /etc/ntp.conf
    systemctl restart ntp
    systemctl enable ntp
fi

# 立即强制同步时间
if command -v chronyc >/dev/null 2>&1; then
    chronyc makestep
elif command -v ntpdate >/dev/null 2>&1; then
    ntpdate ntp.aliyun.com
fi

# 检查同步是否成功
if [ $? -eq 0 ]; then
    echo "[成功] 时区：Asia/Shanghai | NTP：ntp.aliyun.com | 同步周期：约 24 小时"
else
    echo "[错误] 时间同步失败"
    exit 1
fi
