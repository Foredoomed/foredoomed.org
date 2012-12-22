---
layout: post
title: "在VPS上安装dropbear,vsftp和pptpd"
date: 2011-08-21 17:31
---
## 安装Dropbear

首先修改OpenSSH的端口,编辑 /etc/ssh/sshd_config 文件，找到 Port 22 这一行，并修改为 Port 2222。

然后重启OpenSSH：

{% hl %}
service sshd restart
{% endhl %}

编译安装Dropbear:

{% hl %}
cd /data/software
wget http://matt.ucc.asn.au/dropbear/dropbear-0.53.1.tar.gz
tar -zxvf dropbear-0.53.1.tar.gz
cd dropbear-0.53.1
./configure
make && make install
{% endhl %}

生成公钥：

{% hl %}
mkdir /etc/dropbear
/usr/local/bin/dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key
/usr/local/bin/dropbearkey -t rsa -s 4096 -f /etc/dropbear/dropbear_rsa_host_key
{% endhl %}

启动Dropbear：

{% hl %}
/usr/local/sbin/dropbear start
{% endhl %}

配置开机自动启动：

{% hl %}
chkconfig --add dropbear
chkconfig dropbear on
{% endhl %}

Dropbear正确安装完成后，如果能够用ssh登录，那么就可以删除OpenSSH了:

{% hl %}
yum remove openssh
{% endhl %}

## 安装vsftp

如果编译安装的话会报错，要自己手动复制文件，所以我就从软件库自动安装了：

{% hl %}
yum install vsftpd
{% endhl %}

创建FTP用户：

{% hl %}
/usr/sbin/groupadd ftp
/usr/sbin/useradd -g ftp ftp
{% endhl %}

建立FTP默认目录:

{% hl %}
mkdir /var/ftp
{% endhl %}

设定FTP的home目录为/var/ftp：

{% hl %}
useradd -d /var/ftp -s /sbin/nologin ftp
{% endhl %}

设定home目录所有者和权限:

{% hl %}
chown ftp:ftp /var/ftp
chmod 755 /var/ftp
{% endhl %}

编辑vsftp配置文件 /etc/vsftpd/vsftpd.conf，修改为：

{% hl %}
anonymous_enable=no
listen=yes

#并在文件末尾添加：
local_root=/var/ftp/pub
use_localtime=yes
connect_timeout=60
accept_timeout=60
max_clients=10
max_per_ip=10
{% endhl %}

配置开机自动启动

{% hl %}
chkconfig --add vsftpd
chkconfig vsftpd on
{% endhl %}

## 安装pptpd

首先用ssh登录VPS，检查VPS是否有必要的支持，否则将导致无法安装(如果是buyvm的VPS可以跳过这步)

{% hl %}
modprobe ppp-compress-18 && echo ok
{% endhl %}

用模块方式支持MPPE加密模式浏览，如果内核支持则检测不到。如果显示“ok”表明通过，不过还需要做另一个检查：

{% hl %}
cat /dev/net/tun
{% endhl %}

如果显示结果为下面的文本就表明通过：

{% hl %}
cat: /dev/net/tun: File descriptor in bad state
{% endhl %}

上述两条检测只需一条通过，即可安装pptpd。如果还有其他问题，就提Ticket给服务商替你解决。

安装ppp：

{% hl %}
rpm -ivh http://poptop.sourceforge.net/yum/stable/rhel6/i386/ppp-2.4.5-17.0.rhel6.i686.rpm
{% endhl %}

安装pptpd:

{% hl %}
rpm -ivh http://poptop.sourceforge.net/yum/stable/rhel6/i386/pptpd-1.3.4-2.el6.i686.rpm
{% endhl %}

配置pptpd:

{% hl %}
vim /etc/pptpd.conf
{% endhl %}

把下面字段前面的#去掉即可：

{% hl %}
localip 192.168.0.1
remoteip 192.168.0.234-238,192.168.0.245
{% endhl %}

接下来再编辑 /etc/ppp/options.pptpd 文件：

{% hl %}
vim /etc/ppp/options.pptpd
{% endhl %}

去掉 ms-dns 前面的#，并修改成如下字段：

{% hl %}
ms-dns 8.8.8.8
ms-dns 8.8.4.4
{% endhl %}

设置pptpd账号和密码：

编辑 /etc/ppp/chap-secrets 文件：

{% hl %}
vim /etc/ppp/chap-secrets
{% endhl %}

直接输入如下字段,username和password就是你要登录VPN的用户名和密码：

{% hl %}
username pptpd password *
{% endhl %}

修改内核设置，使其支持转发:

编辑 /etc/sysctl.conf 文件：

{% hl %}
vim /etc/sysctl.conf
{% endhl %}

做下面的修改：

{% hl %}
net.ipv4.ip_forward=1
net.ipv4.tcp_syncookies = 1  #注释这行
{% endhl %}

保存退出，并执行下面的命令来使它生效：

{% hl %}
sysctl -p
{% endhl %}

添加iptables转发规则：

{% hl %}
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to-source xxx.xxx.xxx.xxx  #xxx.xxx.xxx.xxx为你的VPS的公网IP地址
{% endhl %}

保存iptables转发规则：

{% hl %}
/etc/init.d/iptables save
{% endhl %}

重启iptables：

{% hl %}
/etc/init.d/iptables restart
{% endhl %}

重启pptpd服务：

{% hl %}
/etc/init.d/pptpd restart
{% endhl %}

设置开机自动启动

{% hl %}
chkconfig --add pptpd
chkconfig pptpd on
{% endhl %}

