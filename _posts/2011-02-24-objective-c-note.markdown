---
layout: post
title: "Objective-C学习笔记"
date: 2011-02-24 14:26
---
## 基本数据类型

![基本数据类型](http://farm6.static.flickr.com/5214/5488573123_a7dfd0551c_z.jpg "基本数据类型")

![基本数据类型](http://farm6.static.flickr.com/5176/5488563233_153dd27348_z.jpg "基本数据类型")

id : 可以保存任何类型的对象，也就是对象的泛型类型。(id类型非常重要，因为他是Objective-C中的重要特性多态和动态绑定的基础)

## 类,对象和函数

(1) 函数调用方式

[ ClassOrInstance method ] 也可以理解为： [ receiver message ]

(2) 类的声明与实现

@interface是类的声明关键字，一般的格式为：

{% hl %}
@interface NewClassName: ParentClassName 
{ 
    memberDeclarations; 
}  
methodDeclarations; 
@end
{% endhl %}

@implementation是类的实现关键字，一般的格式为：

{% hl %}
@implementation NewClassName 
    methodDefinitions; 
@end
{% endhl %}

(3) 自动生成类属性的setter和getter函数的方法

先在类的声明里用**@property**关键字定义类的属性，然后在类实现文件中用**@synthesize**关键字。

(4) self： 本类的实例

(5) @class： 可以让编译器知道要引用的类的类型，但如果用到类中的属性或函数，那就要用 #import “XXX.h“ 来代替。

(6) 如果某个对象调用继承自NSObject中的release函数，那么这个对象只会在没有任何引用的情况下才会释放内存，release函数通过调用实际释放内存的 dealloc函数来实现释放内存的操作(不要重写release函数，而是重写dealloc函数)。

(6) 异常捕获
{% hl %}
@try { 
  statement 
  statement 
  ... 
} 
@catch (NSException *exception) { 
  statement 
  statement 
  ... 
}
{% endhl %}

(7) volatile： 防止编译器优化看似多余的变量赋值

(8) @protocol： 类似于Java中的接口，跟在@interface后尖括号（< ...>）中。声明在@protocol中的函数必须实现，而声明在@optional中的函数可以不实现。

(9) 属性特性

![属性特性](http://farm6.static.flickr.com/5180/5488588537_1f41be3c8e_z.jpg "属性特性")
