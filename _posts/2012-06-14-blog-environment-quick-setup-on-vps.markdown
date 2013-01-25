---
layout: post
title: "在VPS上快速搭建博客环境"
date: 2012-06-14 23:04
---
这次为一个新买的VPS安装博客环境，特此记录如下。

## 0.CentOS 6

### 删除和替换已有软件

{% hl %}

$ servive sendmail stop
$ yum remove sendmail

$ service httpd stop
$ yum remove httpd

$ service rsyslog stop
$ yum remove rsyslog

# 添加EPEL软件库
$ rpm -Uvh http:#dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-7.noarch.rpm

# 添加RPMforge软件库
$ rpm -Uvh http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.i386.rpm

# 安装syslog-ng代替rsyslog
$ yum install syslog-ng
$ chkconfig syslog-ng on

# 安装dropbear代替openssh
$ yum install dropbear
$ chkconfig dropbear on

# 等dropbear配置好后
$ service sshd stop
$ yum remove openssh

# 安装yum-utils
$ yum install yum-utils

# 更新软件
$ yum upgrade

# 安装ppp
$ rpm -Uvh http:#poptop.sourceforge.net/yum/stable/rhel6/i386/ppp-2.4.5-17.0.rhel6.i686.rpm

# 安装pptpd
$ rpm -Uvh http:#poptop.sourceforge.net/yum/stable/rhel6/i386/pptpd-1.3.4-2.el6.i686.rpm

# 安装git
$ yum install git

# 安装nginx
$ rpm -Uvh http:#nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm

$ yum install nginx

# 安装RVM
$ curl -L https://get.rvm.io | bash -s stable

# 安装ruby
$ rvm install 1.9.3

# 配置.gemrc
$ cd ~  
$ vim .gemrc  
# 添加下面这行  
gem: --no-ri --no-rdoc

# 安装vsftpd
$ yum install vsftpd
$ chkconfig vsftpd on

# 添加用户
$ groupadd www
$ useradd -g www username
$ passwd username

# 设定ftp登陆目录权限
$ chown -R usernmae /path/to/ftp/folder

{% endhl %}

### VPS设置

{% hl %}

# 配置vim
$ vim /etc/vimrc

# 加入下面几行
syntax on
set nu
set mouse=a
set tabstop=4

# 禁用IPv6
$ vim /etc/sysconfig/network
NETWORKING_IPV6="no"

# 设置文件最大打开数
$ vim /etc/security/limits.conf
# 加入下面两行
* soft nofile 65535
* hard nofile 65535

# 把服务器时间改为上海时间
$ cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 关闭不需要的服务
$ ntsysv  #按空格选择和取消，按F12退出
{% endhl %}

## 1.Debian

### 设置locale

{% hl %}

$ locale-gen en_US en_US.UTF-8

$ dpkg-reconfigure locales

{% endhl %}

### 删除多余软件

{% hl %}

$ apt-get -y purge apache2-* bind9-* xinetd samba-* nscd-* portmap sendmail-* sasl2-bin

$ apt-get autoremove && apt-get clean

$ apt-get update && apt-get upgrade

{% endhl %}

### 安装nginx

{% hl %}

$ vim /etc/apt/sources.list

# 加入下面两行
deb http://nginx.org/packages/ubuntu/ precise nginx
deb-src http://nginx.org/packages/ubuntu/ precise nginx

$ wget http://nginx.org/keys/nginx_signing.key

$ sudo apt-key add nginx_signing.key

$ apt-get install nginx

{% endhl %}

### 设置时区

{% hl %}

$ dpkg-reconfigure tzdata  #算作Asia/Shanghai

{% endhl %}

