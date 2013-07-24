---
layout: post
title: "用Chef Solo管理单台服务器"
date: 2013-07-24 21:15
---
用Chef来管理多台服务器的话需要有[Chef Server](http://wiki.opscode.com/display/chef/Chef+Server)的配合才能达到目的，但是如果只有一台服务器的话怎么办呢？这个时候就要使用[Chef Solo](http://wiki.opscode.com/display/chef/Chef+Solo)了。

## 0.安装

Chef solo的安装和Chef的安装差不多，依次执行下面几行命令就可以了。

{% hl %}

[foredoomed@nerv dev]# gem install chef --no-ri --no-rdoc
 
[foredoomed@nerv dev]# gem install knife-solo --no-ri --no-rdoc
 
[foredoomed@nerv dev]# git clone https://github.com/opscode/chef-repo.git chef-solo
 
[foredoomed@nerv chef-solo]# mkdir .chef
 
[foredoomed@nerv chef-solo]# echo "cookbook_path [ '/dev/chef-solo/cookbooks' ]" > .chef/knife.rb
 
[foredoomed@nerv chef-solo]# knife cookbook create helloworld

{% endhl %}

在chef-solo文件夹下新建solo.rb文件并加入

{% hl %}

file_cache_path "/dev/chef-solo"

cookbook_path "/dev/chef-solo/cookbooks"

{% endhl %}

再创建chef.json文件并加入

{% hl %}

{
  "run_list": [ "recipe[helloworld]"]
}

{% endhl %}

## 1.使用

到目前为止，chef-solo的准备工作已经完成了，现在可以开始编写cookbook了，还是以经典的hello world为例。

{% hl %}

[foredoomed@nerv chef-solo]# vim cookbooks/helloworld/recipes/default.rb

{% endhl %}

加入下面几行

{% hl %}

execute "hello world" do
  command "echo hello world"
end

{% endhl %}

最后就可以运行看结果了

{% hl %}

[foredoomed@nerv chef-solo]# chef-solo -c solo.rb -j chef.json

{% endhl %}

## 2.总结

用过Chef以后给我的感觉就是非常的麻烦，而且文档方面非常的粗糙，很多东西都没有详细的说明，在这种情况下使用Chef就要慎重考虑了，因为在初期可能比较痛苦。

## 参考资料

* [Installing Chef Server using Chef Solo](http://wiki.opscode.com/display/chef/Installing+Chef+Server+using+Chef+Solo)
* [chef-solo](http://docs.opscode.com/chef_solo.html)
* [Resources and Providers Reference](http://docs.opscode.com/chef/resources.html#notifications)
* [About Resources and Providers](http://docs.opscode.com/resource.html)