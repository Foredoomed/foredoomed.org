---
layout: post
title: "什么是Clean C"
date: 2013-05-27 15:35
---
Clean C(CC)是目前我自己在开发的一种新的语法类似C的解释型语言，今天它的最初版0.0.1版发布了。

现在编程语言那么多，为什么要自己开发一个语言呢？因为我一直想知道编程语言是怎么创造出来的，并且代码又是怎么被计算机执行的。

为了避免要写复杂的汇编代码的麻烦，所以CC跟Java一样都是先被编译成中间字节码文件，然后由CC解释器来解释执行。

因为主要的目的是学习，所以这次并没有使用[Flex](http://flex.sourceforge.net/)和[Bison](http://www.gnu.org/software/bison/)来做词法和语法分析，而是自己来写这两个部分。以后可能会考虑用[LLVM](http://llvm.org/)来改写。

还有CC是用C来写的，名字里有C那当然要用C来写格。但是我写Java有几年了，却从来没写过C，这次正好可以练习写C代码的能力，一举两得。

0.0.1版只实现了一个print函数的功能，比如：

{% hl %}

print("Hello World");

{% endhl %}

然后print函数会被编译成下面这样的「指令」：

{% hl %}

0S11Hello World1

{% endhl %}

「指令」的各个字符表示的含义：

* 0：把Hello World压入栈
* S：表示字符串
* 11：字符串长度
* 1：打印字符串

代码已经放在Github上了：

* [CC](https://github.com/Foredoomed/CC)
* [CC-Compiler](https://github.com/Foredoomed/CC-Compiler)

最后至于名字为什么要叫Clean C？只要你写过C就知道了。

