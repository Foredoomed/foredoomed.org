---
layout: post
title: "在macOS上安装DNSCrypt-Proxy"
date: 2018-05-11 13:01
---
DNSCrypt是一中DNS加密协议，目的在于加密客户端和DNS服务器端之间的通讯，用来防止ISP对DNS协议的恶意劫持，或者部分DNS服务对NXDOMAIN的劫持（对解析失败的域名跳转到广告页面）。

安装DNSCrypt-Proxy

{% hl %}
brew install dnscrypt-proxy
{% endhl %}

安装完成之后，需要配置几个地方，打开文件：

{% hl %}
vim /usr/local/etc/dnscrypt-proxy.toml
{% endhl %}

搜索`log_level`然后修改为：

{% hl %}
log_level = 0
log_file = '/usr/local/var/log/dnscrypt-proxy.log'
{% endhl %}


再搜索`query_log`，然后将`file`那一行修改为：

{% hl %}
file = '/usr/local/var/log/query.log'
{% endhl %}


再搜索`nx_log`，然后将`file`那一行修改为：

{% hl %}
file = '/usr/local/var/log/nx.log'
{% endhl %}


在任何情况下不使用操作系统自带的解析，在文件中搜索`ignore_system_dns`然后修改：

{% hl %}
ignore_system_dns = true
{% endhl %}


启动DNSCrypt-Proxy：

{% hl %}
sudo brew services start dnscrypt-proxy
{% endhl %}


如果服务正常启动了，在`dnscrypt-proxy.log`中应该可以看到下面这行：

{% hl %}
dnscrypt-proxy is ready
{% endhl %}

然后就可以在网络设置中将DNS设置为`127.0.0.1`, 到这里整个安装配置DNSCrypt-Proxy就完成了。
