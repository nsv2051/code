#!/bin/bash

# 检查 SSH 目录是否存在，如果不存在则创建它
if [ ! -d ~/.ssh ]; then
  mkdir ~/.ssh
fi

# 获取当前主机名并将其添加到 /etc/hosts 文件中
HOSTNAME=$(hostname)
echo "127.0.0.1 $HOSTNAME" | sudo tee -a /etc/hosts > /dev/null

# 下载 SSH 密钥并将其添加到 authorized_keys 文件中
curl https://github.com/nsv2051.keys > ~/.ssh/authorized_keys

# 更改 SSH 目录和 authorized_keys 文件的权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# 在 SSH 配置文件中禁用密码验证
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# 重启 SSH 服务以应用更改
sudo service ssh restart
#!/bin/bash

# 检查 SSH 目录是否存在，如果不存在则创建它
if [ ! -d ~/.ssh ]; then
  mkdir ~/.ssh
fi

# 获取当前主机名并将其添加到 /etc/hosts 文件中
HOSTNAME=$(hostname)
echo "127.0.0.1 $HOSTNAME" | sudo tee -a /etc/hosts > /dev/null

# 下载 SSH 密钥并将其添加到 authorized_keys 文件中
curl https://github.com/nsv2051.keys > ~/.ssh/authorized_keys

# 更改 SSH 目录和 authorized_keys 文件的权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# 在 SSH 配置文件中禁用密码验证
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# 重启 SSH 服务以应用更改
sudo service ssh restart
