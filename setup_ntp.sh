#!/bin/bash
# Auto configure timezone and NTP for Debian/Ubuntu

# 设置时区为上海
timedatectl set-timezone Asia/Shanghai

# 安装 Chrony（优先）或 NTP
if ! command -v chrony &>/dev/null; then
  apt-get update
  apt-get install -y chrony || apt-get install -y ntp
fi

# 配置阿里云 NTP 服务器
if [ -f /etc/chrony/chrony.conf ]; then
  sed -i 's/^pool.*/server ntp.aliyun.com iburst/g' /etc/chrony/chrony.conf
  echo -e "maxpoll 17\nminpoll 17" >> /etc/chrony/chrony.conf
  systemctl restart chrony
  systemctl enable chrony
elif [ -f /etc/ntp.conf ]; then
  sed -i 's/^pool.*/server ntp.aliyun.com iburst/g' /etc/ntp.conf
  echo -e "minpoll 17\nmaxpoll 17" >> /etc/ntp.conf
  systemctl restart ntp
  systemctl enable ntp
fi

# 立即强制同步时间
if command -v chronyc &>/dev/null; then
  chronyc makestep 1
elif command -v ntpdate &>/dev/null; then
  ntpdate ntp.aliyun.com
fi

echo "[Success] Timezone: Asia/Shanghai | NTP: ntp.aliyun.com | Sync: 24h"
