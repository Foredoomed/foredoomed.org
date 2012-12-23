---
layout: post
title: "闭包及其在Java中的模拟实现"
date: 2011-02-10 14:04
---
在上一篇博文 [为什么Java匿名内部类中的方法参数必须定义为final](http://liuxuan.info/blog/2011/01/28/java-anonymous-class/ "为什么Java匿名内部类中的方法参数必须定义为final") 中提到在Stackoverflow上搜索答案时，有老外在答案中提到了**Closure**这个词，而这篇博文中就是关于闭包的。

我们先来看一下维基上给出的关于闭包的解释：

> In computer science, a **closure** is a first-class function with free variables that are bound in the lexical > environment. Such a function is said to be "closed over" its free variables. A closure is defined within the scope of > its free variables, and the extent of those variables is at least as long as the lifetime of the closure itself.

第一次看这段英文的解释的时候很难搞懂他的意思，原因在于其中出现了较多第一次碰见的计算机编程领域的专业术语，如果不把这些专业术语搞明白的话整段话就自然而然搞不明白了。

我们来逐个看一下这些专业名词，首先第一个是**first-class function**。有一个与first-class function对应的名词是first-class object，维基上给出的解释是：第一类对象是个实体，它可以被当作函数的参数，可以从子程序中返回，可以赋值给变量。那么套用到first-class function的话就是：如果某种函数可以作为其他函数的参数传入，可以赋值给变量，可以被函数动态的创建和返回，那么这类函数被称为first-class function即第一类函数。

看了这个定义后你可能会有这样一个疑问：在命令式编程语言（例如Java）中我们也可以把返回类型不是void的函数的调用作为另一个函数的参数传入。其实在这个场景里，函数参数的类型还是基本类型或者引用类型，我们只是把原来的两行代码写在了一行里，真正传入的还是基本类型或者引用类型。而第一类函数可以作为参数传入另一个函数是指：可以在一段程序的执行过程中可以创建新的函数，可以在数据结构中保存新创建的函数，可以把这些新创建的函数作为参数传给其他函数，并且可以作为其他函数的返回值。也就是说其他函数可以把第一类函数（整个声明体或匿名）做为他的参数存在，这是和一般的命令式编程语言很大的区别（C#等混合语言除外）。

好了，上面只是文字上的解释，我们来看一下第一类函数的例子：

1. 第一类函数赋值给变量，这个函数的作用是对每个Int类型的值都加1：
	{% hl %}
	var increase = (x : Int) => x + 1
	{% endhl %}

2. 第一类函数作为参数传给另一个函数，这个函数的作用是打印集合中的每个元素：
	{% hl %}
	List.foreach((x : Int) => println(x))
	{% endhl %}

3. 第一类函数作为返回值，这个函数的作用是对x求导：
	{% hl %}
	using System;
	
	class Program
	{
      // f: function that takes a double and returns a double
      // deltaX: small positive number
      // returns a function that is an approximate derivative of f
      static Func＜double , double＞ MakeDerivative(Func＜double , double＞ f, double deltaX)
      {
       	return x => (f(x + deltaX) - f(x)) / deltaX;
      }
    	
      static void Main()
      {
    	var cos = MakeDerivative(Math.Sin, 0.00000001);
    	Console.WriteLine(cos(0));                    // 1
    	Console.WriteLine(cos(Math.PI / 2));          // 0
      }
	}
	{% endhl %}

我们再来看看**free variable（自由变量）**是个什么东西。维基上的解释是：自由变量是一个函数中的变量，并且既没有在上下文声明过，也不是函数的参数，并且会在函数的创建执行过程中被特定的值替换。lexical environment可以理解为变量的作用域。

现在我们可以来翻译这段关于闭包的解释了：
> 闭包是第一类函数和自由变量绑定在作用域中，这种函数被称为“关闭”他的自由变量。闭包是被定义在他的自由变量的作用域中，并且这些自由变量的生命周期至少跟闭包本身的生命周期一样。
因为闭包需要的第一类函数和自由变量是函数式编程语言必须的要素，所以闭包更多的是在函数式编程语言中应用（JavaScript除外）。而Java不支持第一类函数，所以Java目前还不支持闭包（至少目前不支持），但是我们可以通过内部类来模拟闭包。

{% hl %}
final User user = new User();
new AbstractExecutionThreadService() {
    @Override
    protected void run() throws Exception {
    mailManager.sendActivateMail(user);
    }
}.start();
{% endhl %}

其实关于Java引入闭包的争论由来已久，几个月之前有消息说在JDK 7中将支持lamda表达式。我也看过Java的lamda语法的示例，但是看过后就感觉即使把那些蛋疼的语法加入到Java中去，是不是也会有蛋疼的程序员去用？如果蛋疼的程序员写了蛋疼的代码，那读代码的人岂不是更蛋疼？

现在已经有很多OO和FP混合的语言，比如Scala,Ruby,Python，C#现在更是把动态语言的特性也引入进去。我想说是不是真的有必要这么做？以C#为例，Linq可以把几行的循环代码等价转换成只有一行代码，这确实提高了编码效率。但是从我的感受来说，如果大段的命令式代码中突然夹杂了几行函数式的代码有一种非常强烈的跳跃感，除非你对命令式和函数式语言都非常的熟悉。

语言之争（或者平台之争）一直是在激烈的持续着，这种情况下有点像冷战思维也不觉得奇怪，但是我觉得Java没必要跟C#学，C#想把自己变成一把瑞士军刀，但是，我们日常生活中有多少机会会用到这把功能虽多但很难用的刀呢？
