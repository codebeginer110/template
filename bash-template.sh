#!/bin/bash

#Author:		zouahaiqiang1
#Version: 		1.0
#Date:			2023/1/9
#Last Updated:	2023/1/9
#Contact:		zouhaiqiang1@xiaomi.com
#Organization:	xiaomi/mit/b2csre
                                  
###==============Watch Nginx configuration================
###监控nginx conf目录文件变化，若发生变化，则进行语法校验，重载配置。
###Usage:
###  ./watch_ngx_conf.sh
###Options:
###  -w/--watch path   	设置监控目录，默认当前目录下的conf文件夹
###  -o/--output		指定输出日志，默认输出到终端,不记录日志
###  -h/--help			打印帮助文档

help(){
	sed -rn 's/^### ?//p;' "$0"
}
watch(){
	watch_dir=$1
	log_path=$2
	fswatch -0 $watch_dir | while read -d "" file;
	do
		reason=$(sudo nginx -t 2>&1 | sed -n '1p')
		echo $reason |grep "syntax is ok" > /dev/null
		if [ $? -eq 0 ];
		then
			echo $(date +"%Y-%m-%d %H:%M.%S") $file "success" >> $log_path
			sudo nginx -s reload 2>&1 > /dev/null
		else			
			echo $(date +"%Y-%m-%d %H:%M.%S") $file "failed" $reason >> $log_path
		fi	
	done
}

#======== Main =========#

#默认参数
watch_path='./conf/vhost'
output=$(tty)

#参数解析
while [[ $# -gt 0 ]]; 
do
  	arg=$1
  	case $arg in 
		-w|--watch)
		watch_path=$2
		shift
		shift
		;;
		-o|--output)
		output=$2
		shift
		shift
		;;
		-h|--help)
		help
		shift
		;;
	esac
done

#参数校验
if [ -d $watch_path ] && [ -d $(dirname $output) ];
then
	watch $watch_path $output
else
	help
	echo "\033[31m Invaild arguments:$ \033[0m"
fi