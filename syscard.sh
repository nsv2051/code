#!/bin/bash
 
welcome=$(uname -r)
 
# CPU型号
cpu_model=$(lscpu | grep "Model name:" | sed 's/Model name: *//')
 
# GPU型号
gpu_model=$(lspci | grep -i vga | sed 's/.*: //')
 
# 内存
memory_total=$(free -m | awk 'NR==2 { printf($2)}')
if [ $memory_total -gt 0 ]
then
memory_usage=$(free -m | awk 'NR==2 { printf("%3.1f%%", $3/$2*100)}')
else
memory_usage=0.0%
fi
 
# 交换内存
swap_total=$(free -m | awk 'NR==3 { printf($2)}')
if [ $swap_total -gt 0 ]
then
swap_mem=$(free -m | awk 'NR==3 { printf("%3.1f%%", $3/$2*100)}')
else
swap_mem=0.0%
fi
 
# 磁盘使用情况
usageof=$(df -h / | awk '/\// {print $(NF-1)}')
 
# 系统负载
load_average=$(awk '{print $1}' /proc/loadavg)
 
# 当前用户
whoiam=$(whoami)
 
# 运行天数
updays=$(uptime | awk '{print $3}')
 
# 当前时间
time_cur=$(date "+%Y-%m-%d %H:%M:%S")
 
# 进程数量
processes=$(ps aux | wc -l)
 
# 在线用户数量
user_num=$(users | wc -w)
 
# 上次登录时间
last_login=$(last -n 1 -a | head -n 1)
 
# 系统版本
system_version=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d= -f2 | tr -d '"')
 
# IP地址
ip_pre=""
if [ -x "/sbin/ip" ]
then
ip_pre=$(/sbin/ip a | grep inet | grep -v "127.0.0.1" | grep -v inet6 | grep eth | awk '{print $2}')
fi
 
# 增加更多颜色和视觉效果
function print_with_color() {
local text=$1
local color=$2
echo -e "\033[${color}m${text}\033[0m"
}
 
print_with_color "系统信息如下时间: \t$time_cur" "1;34"
print_with_color "CPU型号: \t\t$cpu_model" "1;33"
print_with_color "GPU型号: \t\t$gpu_model" "1;33"
print_with_color "系统版本: \t\t$system_version" "1;36"
print_with_color "系统运行天数: \t\t$updays天" "1;36"
print_with_color "系统负载: \t\t$load_average" "1;33"
print_with_color "进程数量: \t\t$processes" "1;36"
print_with_color "内存使用: \t\t$memory_usage" "1;35"
print_with_color "交换内存使用: \t\t$swap_mem" "1;35"
print_with_color "磁盘/目录使用情况:\t$usageof" "1;36"
print_with_color "上次登录时间: \t\t$last_login" "1;34"
 
for line in $ip_pre
do
ip_address=${line%/*}
print_with_color "IP地址: \t\t$ip_address" "1;34"
done
 
print_with_color "在线用户数量: \t\t$user_num" "1;33"
 
if [ -f "/var/infomation/msg.txt" ]; then
pkgnum=$(cat /var/infomation/msg.txt | awk -F':' '{print $2}')
if [ -n "$pkgnum" ]; then
awk -F":" '{print $1":\t"$2}' /var/infomation/msg.txt
fi
fi
