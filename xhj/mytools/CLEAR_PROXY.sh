#/bin/bash

env|grep -i proxy|awk -F= -va="unset " -vb="&&" '{print a$1b}'>proxys.txt 
cat proxys.txt|xargs|sed 's/\&\& /\&\&/g'|sed 's/\&\&$//g'

