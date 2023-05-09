#!/bin/bash

# 从环境变量中获取授权密钥的 URL
authorized_keys_url=https://github.com/nsv2051.keys

# 从 URL 下载授权密钥文件
curl -sSL "$authorized_keys_url" > /tmp/authorized_keys

# 检查授权密钥文件是否下载成功
if [ ! -s /tmp/authorized_keys ]; then
  echo "Failed to download authorized keys from $authorized_keys_url"
  exit 1
fi

# 将授权密钥文件添加到目标服务器的 ~/.ssh/authorized_keys 文件中
ssh_target() {
  ssh -o "StrictHostKeyChecking=no" "$@" -t '
    # 创建 ~/.ssh 目录和 authorized_keys 文件（如果不存在）
    mkdir -p ~/.ssh
    touch ~/.ssh/authorized_keys

    # 将授权密钥文件追加到 authorized_keys 文件中
    cat /tmp/authorized_keys >> ~/.ssh/authorized_keys

    # 禁用密码登录
    sudo sed -i -e "s/^#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
    sudo systemctl reload sshd
  '
}

# 执行 ssh_target 函数，传入目标服务器的地址和用户名
ssh_target user@host
