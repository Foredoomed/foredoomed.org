---
layout: post
title: "浏览器是如何工作的(一)"
date: 2011-12-05 23:03 
---
浏览器可能是目前使用的人最多的软件，对于软件开发人员来说更是如此。我对浏览器的认识差不多是这样的：

* 发送请求到服务器(get/post)
* 解析从服务器返回的response(HTML,CSS)
* 执行JavaScript代码

基本上就是上面这些，但是至于细节就不了解了。直到我看到了这篇长长的文章：[How Browsers Work:Behind the Scenes of Modern Web Browsers](http://www.html5rocks.com/en/tutorials/internals/howbrowserswork/ "How Browsers Work:Behind the Scenes of Modern Web Browsers"),才第一次窥探到了浏览器的处理细节。这个主题一共分成了10章来讲，对于学习和参考浏览器的工作原理都非常有用。所以，我就决定把它翻译成中文，供以后参考用。值得一提的是，这篇文章的作者是一个有着10年以上经验的女程序员，让我们像她致敬！

由于原文较长，所以我也会分成几篇博客来翻，而这篇博客是这个系列的第一篇翻译。

## 1 引子

浏览器可能是目前使用最广的软件。在这个系列的文章中，我将解释浏览器是如何工作的。我们将会看到在浏览器的地址栏中敲入google.com到你看到google的页面这段时间内到底发生了什么。

### 1.1 我们将会讨论的浏览器

现在有5个主流的浏览器，他们是：IE,Firefox,Safari, Chrome和Opera。我会从开源浏览器Firefox,Chrome以及部分开源的Safari中举例。根据[StatCounter browser statistics](http://gs.statcounter.com/ "StatCounter browser statistics")上的统计，到2011年8月为止，Firefox,Chrome和Safari三者加起来的占有率已经到达将近60%。所以开源浏览器是浏览器领域的重要组成部分。

### 1.2 浏览器的主要功能

浏览器的主要功能是展现用户选择的网络资源，这是通过发送请求给服务器并且在浏览器中显示返回结果。而这个网络资源一般是一个HTML文档，但也有可能是PDF，图片或者其他类型的资源。资源的地址是通过URI来描述的。

浏览器解释和显示HTML文件的方式是在HTML和CSS规范里面规定的。这些规范是由[W3C](http://www.w3.org/ "W3C")维护的。

多年以来，那些浏览器只遵守了一部分的规范，并且开发他们自己的扩展。但是这就给开发人员带来了严重的兼容性问题。目前大多数浏览器或多或少遵守着规范。

浏览器的用户接口基本上差不多，他们有：

* 地址栏
* 后退和前进按钮
* 书签选项
* 刷新和停止按钮
* 主页按钮

奇怪的是，浏览器的用户接口并有在任何正式的规范里规定过，而是来自于多年经验形成的最佳实践，还有浏览器之间的相互模仿。HTML5规范并没有规定浏览器必须具有的UI元素，但是它列出了一些共有的元素。在他们之中有地址栏，状态栏和工具栏。当然，浏览器也可以有自己独特的特性，比如Firefox的Download Manager。

### 1.3 浏览器的结构概览

1. 用户接口 - 前面已经提到过
2. 浏览器引擎 - 处理UI和渲染引擎之间的行为
3. 渲染引擎 - 负责显示请求的内容。比如解析HTML和CSS后显示出来。
4. 网络 - 用来网络调用，比如HTTP请求。它是不依赖于平台并且实现隐藏于平台之下。
5. UI后端 - 用来画基本的组合框和窗口。它暴露一个不依赖平台的通用接口，在它之下使用的是操作系统的用户接口方法。
6. JavaScript解释器 - 解析和执行JavaScript代码
7. 数据存储 - 这是一个持久层，浏览器需要保存所有类型的数据到硬盘上，比如cookie。而HTML5规定了浏览器的数据库web database。

![layers](http://i1256.photobucket.com/albums/ii494/Foredoomed/layers_zps14cc9cb9.png "layers")

需要注意的是，Chrome跟大多数浏览器不一样的是，它会有多个渲染引擎的实例，每个标签页都有一个渲染引擎，每个标签页是个独立的进程。

