---
layout: post
title: "定制Manjaro"
date: 2018-02-08 19:14
---
首先官网下载Manjaro的ISO文件，然后用[rufus](http://rufus.akeo.ie/)将镜像写入U盘再安装。

##0. 切换中国源
{% hl %}
$ sudo pacman-mirrors -c China
$ sudo pacman-optimize && sync
$ sudo pacman -Syyu
{% endhl %}

##1. 安装archlinuxcn-keyring
{% hl %}
$ sudo pacman -S archlinuxcn-keyring
{% endhl %}

如果安装失败就执行：

{% hl %}
$ sudo pacman -Syu haveged
$ sudo systemctl start haveged
$ sudo systemctl enable haveged
$ sudo rm -rf /etc/pacman.d/gnupg
$ sudo pacman-key --init
$ sudo pacman-key --populate archlinux
$ sudo pacman -S archlinuxcn-keyring
$ sudo pacman-key --populate archlinuxcn
$ sudo pacman -Syy && sudo pacman -S archlinuxcn-keyring
{% endhl %}

##2. 安装yaourt和pacaur
{% hl %}
$ sudo pacman -S yaourt pacaur
{% endhl %}

##3. 安装fish shell
{% hl %}
$ sudo pacman -S fish
$ chsh -s /usr/bin/fish 
{% endhl %}

##4. 安装Mac主题
下载[主题](https://github.com/paullinuxthemer/Gnome-OSX)到`~/.themes`, 下载[图标](https://github.com/keeferrourke/la-capitaine-icon-theme/)到`~/.icons`。
然后在Tweak Tool中设置刚才下载的主题和图标。


