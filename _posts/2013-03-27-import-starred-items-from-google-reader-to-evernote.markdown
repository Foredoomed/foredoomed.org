---
layout: post
title: "导入Google Reader中的标星项到Evernote"
date: 2013-03-27 21:31
---
Google宣布从2013年7月开始关闭Google Reader，这个消息对于我这样的重度用户来说无疑是一道晴空霹雳，一时间我都在为找它的替代品而
忙碌。经过试用后发现[theoldreader](http://http://theoldreader.com/)是一个不错的选择，但是它不能把标星项也导入进去，所以自己写了个脚本来导入到Evernote中去。

{% hl %}
# A script for exporting all starred items from Google Reader to Evernote,
# using exported [starred.json] from Google's Takeout

#! /usr/bin/env ruby

require 'rubygems'
require 'json'


if File.exists?("starred.json")

  file = open("starred.json", "r:utf-8")
  json = file.read
  parsed = JSON.parse(json)

  parsed["items"].each_with_index {|item,i|

      file_name = "#{i}" + ".html"
      enex = File.open(file_name, "w+")
      enex.puts '<head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /></head>'
      enex.puts item["content"]["content"] unless item["content"].nil?

  }

else
  STDERR.print "ERROR: starred.json does not exist\n"
  exit 1
end
{% endhl %}

代码非常简单，首先分析你的starred.json(这个文件可以在Google Takeout的压缩包中找到)，然后把其中的标星项导出为html。这是因为我试了一下导出为enex格式的文件后再导入Evernote的话，含有html标签的正文内容就无法显示。
如果把html标签去掉的话格式又有问题，所以退而求其次先导出为html再导入到Evernote。

导出成功后再把html拖曳到Evernote的图标上就可以，唯一的缺点是在导入过程中会下载东西，按取消就可以了。

代码已经放到[Github](https://github.com/Foredoomed/GR2EN)上了.
