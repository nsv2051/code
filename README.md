# 一键设置密钥登陆
 ```
 curl -s https://gitproxy.eu.org/https://raw.githubusercontent.com/nsv2051/code/main/add_ssh_key.sh | bash
 ```
# Time Sync Script

这是一个用于设置系统时区并同步时间的 shell 脚本，适用于多种 Linux 系统。它将时区设置为 `Asia/Shanghai`，并通过 `ntpdate` 从 `pool.ntp.org` 同步时间，同时设置每小时自动同步的 cron 任务。

## 功能
- 设置系统时区为 `Asia/Shanghai`
- 检查并自动安装 `ntpdate`（支持 `apt`、`yum`、`dnf`、`pacman`）
- 立即同步系统时间
- 添加每小时第 1 分钟自动同步时间的 cron 任务

## 前提条件
- 需要 root 权限运行（建议使用 `sudo`）
- 需要网络连接以安装依赖和同步时间

## 使用方法

### 一键执行（推荐）
通过 `curl` 或 `wget` 直接从 GitHub 下载并运行脚本：

#### 使用 curl
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/nsv2051/code/main/sync-time.sh)"
```
#### 使用 wget
```bash
bash -c "$(wget -qO- https://raw.githubusercontent.com/nsv2051/code/main/sync-time.sh)"
```
# mtg一键
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nsv2051/code/main/automtg.sh)

```
