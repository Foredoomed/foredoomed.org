---
layout: post
title: "用Chef来管理服务器"
date: 2013-06-29 13:41
---

##0.介绍Chef##

我们每次搭建一个新的服务器的时候都会给它安装和配置一堆软件，比如Web服务器Apache，Nginx；数据库MySQL，PostgreSQL等。如果是一，两台服务器的话手动安装这些软件还不会太痛苦，但是如果要给几十台，甚至上百台服务器安装的话那就是要命的事了。在后面这种情况下我们希望这些工作能自动化来完成，而Chef就是用来做这件事的。

##1.安装Chef##

Chef包括**Chef Server**和**Chef Client**。Chef Server是保存软件安装描述文件(Cookbook)的地方，需要安装软件的时候只要发个JSON请求到Chef Server就行了，其余的事情Chef都会帮我们来完成。

为了方便，我就不搭建Chef Server了，直接使用[OPSCODE](http://www.opscode.com/)提供的托管Chef Server服务。在Opscode上注册完成后，新建一个[Organization](https://manage.opscode.com/organizations)，完成后下载**ORGNAME-validator.pem**，**USERNAME.pem**和**knife.pem**三个文件。

接下来安装Chef Client，用最简单的安装方法：

{% hl %}
foredoomed@nerv:~# curl -L https://www.opscode.com/chef/install.sh | sudo bash
{% endhl %}

验证下安装是否成功

{% hl %}
foredoomed@nerv:~# chef-client -v
Chef: 11.4.4
{% endhl %}

##2.配置Chef##

首先我们需要个工具来管理很多Chef的文件，Opscode就提供了个叫[chef-repo](https://github.com/opscode/chef-repo)的工具，我们就用这个工具来管理我们的cookbook。

{% hl %}
foredoomed@nerv:~# git clone https://github.com/opscode/chef-repo.git
{% endhl %}

完成后在chef-repo文件夹下可以看到下面这些文件

{% hl %}
foredoomed@nerv:~# cd chef-repo
foredoomed@nerv:~# ls
LICENSE            chefignore         environments       roles              README.md          config                 
Rakefile           cookbooks          certificates       data_bags
{% endhl %}

接下来就可以用Chef的命令行工具**knife**来管理我们的cookbook了，不过首先需要配置一下。

把之前在Opscode上下载的两个pem文件放到/etc/chef/文件夹下，然后创建client.rb文件

{% hl %}
foredoomed@nerv:~# cd /etc/chef
foredoomed@nerv:~# knife configure client ./
{% endhl %}

然后编辑client.rb文件

{% hl %}
log_level              :info
log_location           STDOUT
chef_server_url        'https://api.opscode.com/organizations/ORGNAME'
validation_key         "/etc/chef/ORGNAME-validator.pem"
validation_client_name 'ORGNAME-validator'
{% endhl %}

回到chef-repo文件夹下创建.chef隐藏文件并修改cookbook文件夹目录，然后把从Opscode上下载的knife.rb文件放到这个文件夹下。

{% hl %}
foredoomed@nerv:~# mkdir .chef
foredoomed@nerv:~# echo "cookbook_path ["#{current_dir}/cookbooks"]" > .chef/knife.rb
{% endhl %}

##3.配置cookbook##

Chef社区已经有许多现成的cookbook了，我们可以直接那过来用

{% hl %}
foredoomed@nerv:~# knife cookbook site download nginx
Downloading mysql from the cookbooks site at version 3.0.2 to ~/development/chef-repo/cookbook/nginx-1.7.0.tar.gz
Cookbook saved: ~/development/chef-repo/cookbook/nginx-1.7.0.tar.gz
foredoomed@nerv:~# tar zxvf nginx-1.7.0.tar.gz
{% endhl %}

现在就可以上传cookbook了

{% hl %}
foredoomed@nerv:~# knife cookbook upload nginx
{% endhl %}

nginx的cookbook需要依赖其他的cookbook，只要依次全部上传就可以了。

最后创建chef.json文件

{% hl %}
foredoomed@nerv:~# cd chef-repo
foredoomed@nerv:~# touch chef.json
{% endhl %}

然后加入

{% hl %}
{
  "run_list": [ "recipe[nginx]" ]
}
{% endhl %}

执行Chef Client安装命令

{% hl %}
foredoomed@nerv:~# chef-cliet -j chef.json
Starting Chef Client, version 11.4.4
...
Chef Client finished, 14 resources updated
{% endhl %}

到目前为止，nginx已经安装完成。最后要吐槽下Chef的文档，连个Hello World都没有，害得我还要到处搜。

##参考资料##

* [Cookbook Fast Start Guide](http://wiki.opscode.com/display/chef/Cookbook+Fast+Start+Guide)
* [Configuring Chef Client](http://wiki.opscode.com/display/chef/Configuring+Chef+Client)
* [knife cookbook](http://docs.opscode.com/knife_cookbook.html)
* [Common Errors](http://wiki.opscode.com/display/chef/Common+Errors)