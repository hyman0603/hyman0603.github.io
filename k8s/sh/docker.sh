#!/bin/bash
# 使用阿里源安装 docker
# used for centos7.4
# Blog http://hyman.shop

[[ $UID -ne 0 ]] && { echo "Must run in root user !";exit; }

#CentOS / RHEL / Fedora
if [[ -f /etc/redhat-release ]];then
  curl -s http://hyman.shop/sh/docker-centos.sh |bash

else
  echo "I don't know the OS"
  exit
fi

##############################