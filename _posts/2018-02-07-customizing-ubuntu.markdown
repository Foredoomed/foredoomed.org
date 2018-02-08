---
layout: post
title: "定制优化Ubuntu"
date: 2018-02-07 11:19
---
##0. 安装Flatabulous主题和图标
{% hl %}
$ sudo add-apt-repository ppa:noobslab/themes 
$ sudo apt-get update 
$ sudo apt-get install flatabulous-theme

$ sudo add-apt-repository ppa:noobslab/icons 
$ sudo apt-get update 
$ sudo apt-get install ultra-flat-icons
{% endhl %}

##1. 安装文泉驿微黑字体
{% hl %}
$ sudo apt-get install fonts-wqy-microhei
{% endhl %}

##2. 安装终端字体
先从[这里](https://github.com/powerline/fonts)下载字体，解压后进入目录执行：
{% hl %}
$ ./install.sh
{% endhl %}

##3. 安装浏览器
{% hl %}
$ sudo apt-get install chromium-browser

或者

$ wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 
$ sudo gdebi google-chrome-stable_current_amd64.deb
{% endhl %}


##4. 安装Flash Player
{% hl %}
$ sudo apt-get install pepperflashplugin-nonfree
{% endhl %}

如果安装失败，可以使用下面的命令重新安装：
{% hl %}
$ sudo dpkg-reconfigure pepperflashplugin-nonfree
{% endhl %}

##5. 安装多媒体解码器
{% hl %}
$ sudo apt-get install ubuntu-restricted-extras
{% endhl %}

##6. 安装rar工具
{% hl %}
$ sudo apt-get install unace p7zip-rar sharutils rar arj lunzip lzip
{% endhl %}

##7. 安装剪贴板管理器
{% hl %}
$ sudo apt-get install glipper
或者
$ sudo apt-get install clipit
{% endhl %}

##8. 修改日期格式
修改日期格式为12小时格式显示月份名称、日期和时间。在”使用自定义日期格式”的选框中填入
{% hl %}
%B %e, %I:%M %p
{% endhl %}

##9. 安装Guake
{% hl %}
$ sudo apt-get install guake
{% endhl %}

Guake需要配置，以便在每次登陆时启动。系统设置 > 启动程序，然后点击添加`/usr/bin/guake`

##10. 安装unity-tweak-tool
用这个工具设置刚才安装的主题，图标，字体等。
{% hl %}
$ sudo apt-get install unity-tweak-tool
{% endhl %}

##11. 安装gnome-tweak-tool
用这个工具设置开机启动项。
{% hl %}
$ sudo apt-get install gnome-tweak-tool
{% endhl %}

##12. 安装fish shell
{% hl %}
$ sudo apt-get install fish
{% endhl %}

##13. 清除不必要的包
{% hl %}
$ sudo apt-get autoremove
{% endhl %}
