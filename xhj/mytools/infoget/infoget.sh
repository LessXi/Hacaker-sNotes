#!/bin/bash

mkdir result/$1     #创建项目文件夹
cd ./subDomainsBrute&&python3 subDomainsBrute.py --full $1 -o ../tmpinfo/1$1.txt     #使用subDomainsBrute工具，并把结果保存到临时目录下
cd ../Sublist3r&&python3 sublist3r.py -d $1 -o ../tmpinfo/2$1.txt 
cd ../teemo&&python teemo.py -d $1 -o ../../tmpinfo/3$1.txt 

cd ../tmpinfo                                       #进入临时目录
cat 3$1.txt|grep @ >> $1mail                        #从teemo的执行结果中提取邮箱
cat 3$1.txt|grep -v @|grep $1 >> $1domain           #从teemo的执行结果中提取子域名
cat 3$1.txt|grep -v @|grep -v $1 >> $1ip            #从teemo的执行结果中提取资产ip
cat 1$1.txt|awk '{print $1}' >> $1domain            #从subDomainsBrute的执行结果中提取子域名
cat 1$1.txt|awk '{print $2}'|sed 's/,//g' >> $1ip   #从subDomainsBrute的执行结果中提取资产ip
cat 2$1.txt >> $1domain                             #从Sublist3r的执行结果中提取子域名
cat $1domain|sort|uniq >> $1domains                 #对提取出的子域名进行排序去重处理
cat $1mail|sort|uniq >> $1mails                     #对提取出的邮箱进行排序去重处理
cat $1ip|while read line                            #对提取出的资产ip进行网段计算
do
	ipcalc $line/28|grep Network|awk '{print $2}' >> $1ips.txt
done

cat $1ips.txt|sort|uniq >> $1ips                    #对计算出的资产ip网段列表进行排序去重处理

#把处理好的子域名、资产ip网段、邮箱等文件放入相应的项目文件夹
mv $1ips $1domains $1mails ../result/$1             
cd ../result/$1
mv $1ips ips&&mv $1domains domains&&mv $1mails mails

#使用masscan扫描资产ip网段列表中开放的1-10000端口
masscan -p 1-10000 -iL ips --rate 10000 -oL portinfo
masscan -p 1-65535 -iL ips --rate 10000 -oL allpinfo &

cat domains >> doaip
awk '{print $4 ":" $3}' portinfo >> doaip
whatweb -i doaip --no-error --grep="200" --log-verbose=webinfo &    #对爆破出来的子域名和开放端口的ip进行web探测，检查其是否启动了web服务
python3 ../../vulmap/vulmap.py -f doaip -t 50 --output-text vulinfo &   #使用vulmap对爆破出来的子域名和开放端口的ip进行漏洞扫描


