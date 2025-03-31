#!/bin/bash
# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 权限运行此脚本（使用 sudo）"
    exit 1
fi

# 设置时区并同步时间
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
(command -v ntpdate >/dev/null 2>&1 || \
(command -v apt >/dev/null 2>&1 && apt update && apt install -y ntpdate) || \
(command -v yum >/dev/null 2>&1 && yum install -y ntpdate) || \
(command -v dnf >/dev/null 2>&1 && dnf install -y ntpdate) || \
(command -v pacman >/dev/null 2>&1 && pacman -S --noconfirm ntp)) && \
ntpdate pool.ntp.org && \
{ crontab -l 2>/dev/null | grep -q ntpdate || echo "* 1 * * * ntpdate pool.ntp.org >/dev/null 2>&1" | crontab -; }

# 检查执行结果
if [ $? -eq 0 ]; then
    echo "时间同步成功：$(date)"
else
    echo "时间同步失败，请检查网络或权限"
fi
