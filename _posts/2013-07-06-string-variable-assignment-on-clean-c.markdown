---
layout: post
title: "Clean C 0.0.2 : 支持字符串变量赋值"
date: 2013-07-06 11:05
---
终于，在0.0.1版本之后的一个月，0.0.2版可以发布了。托了一个多月的原因除了工作比较忙之外，还有就是对C的不了解，饶了很多弯路，不过不要紧，0.0.2版的发布就是一个成功。

在0.0.2版里只增加了一个功能：支持字符串变量赋值。现在你可以像Java那样对一个字符串变量来赋值，只不过关键字是小写的**string**而已。

{% hl %}

string foo = "bar";
string bar = "foo";

print(foo);
print(bar);

{% endhl %}

当然，变量之间也可以赋值

{% hl %}

foo = bar;
bar = "foobar";

print(foo);
print(bar);

{% endhl %}

没有什么特别的地方，每个编程语言都支持的功能，但是这是个开始，下一步就是支持整型变量的赋值，比如 int foo = 1024等。

源代码可以在GitHub上了： 

* [编译器](https://github.com/Foredoomed/CC-Compiler)
* [解释器](https://github.com/Foredoomed/CC)