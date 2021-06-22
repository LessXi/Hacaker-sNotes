#!/bin/bash

rm -rf tmpinfo result
mkdir result tmpinfo

threadNum=20
cat $1|xargs -n1 -P $threadNum ./infoget.sh





