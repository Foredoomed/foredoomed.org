---
layout: post
title: Objective-C的对象模型
date: 2014-02-24 19:49
---
Objective-C是一门面向对象，并且在C的基础上加入了Smalltalk式的消息机制而形成的编程语言，它主要被苹果公司用于开发Mac OS X和iOS操作系统。既然Objective-C是面向对象的编程语言，那么我感兴趣的就是对象在内存中是怎么组织和表示的，消息机制又是怎么实现的。
 
##0.NSObject
 
NSObject类和Java中的Object类有点相似，都是所有一切类的父类，也就是根类。那么NSObject又是一个怎样的类呢。打开NSObject.h头文件就可以看到NSObject的源码：
 
{% hl %}
 
@interface NSObject <NSObject>
{
    Class isa;
}
 
{% endhl %}
 
可以看到NSObject是实现了NSObject protocol的Interface，它里面只包含了一个类型为Class的isa属性。isa是『is a』的意思，连起来就是『is a class』，也就是说这个属性保存了有关类的信息。同样来看一下Class的源码，它被定义在objc.h头文件中：
 
{% hl %}
 
typedef struct objc_class *Class;
 
{% endhl %}
 
Class是objc_class类型，objc_class被定义在objc-class.h：
 
{% hl %}
 
struct objc_class {			
	struct objc_class *isa;	
	struct objc_class *super_class;	
	const char *name;		
	long version;
	long info;
	long instance_size;
	struct objc_ivar_list *ivars;
 
#if defined(Release3CompatibilityBuild)
	struct objc_method_list *methods;
#else
	struct objc_method_list **methodLists;
#endif
 
	struct objc_cache *cache;
 	struct objc_protocol_list *protocols;
};
 
{% endhl %}
 
objc_class是一个结构体，它包含了所有运行时需要的有关类的信息，包括这个类的父类是什么类，实例变量，方法，协议等。有趣的是，objc_class中也有一个isa属性，那么它又指向哪里呢？它指向的是一个叫做metaclass的对象，并且类型也是objc_class。所以实例化一个类会有两个对象：本身和metaclass对象。这样做的目的是把实例方法的信息保存到自己本身的类中，而把类方法保存到metaclass类里。那么metaclass中的isa指向哪里呢？因为metaclass类是没有metaclass方法的，所有就不需要再多一个类来保存metaclass类的方法信息，因此，metaclass对象的isa指向自己，形成一个闭环结构。
 
##1.消息机制
 
在Objective-C中，方法的调用和其他面向对象语言(例如Java)有点区别。在Java中的方法调用可以写成一般形式为：
 
{% hl %}
 
object.method(argument);
 
{% endhl %}
 
但是在Objective-C里要这样写：
 
{% hl %}
 
[object method:argument];
 
{% endhl %}
 
两者的区别是：Java的方法调用是直接调用实例对象的方法，而Objective-C则是发送消息一个消息。发送消息的目标在编译时是不知道的，而是在运行时决定。方法是由selector或者SEL确定的，也就是表示方法名的字符串。消息的接收对象不能保证一定会返回结果，当这种情况发生时就会抛出异常。
 
编译器会把发送消息的语句
 
{% hl %}
 
[receiver message]
 
{% endhl %}
 
转换为：
 
{% hl %}
 
objc_msgSend(receiver, selector, arg1, arg2, ...)
 
{% endhl %}
 
在objc_msgSend方法中做的是通过receiver和selector找到要调用的方法，这个方法的类型是IMP型的，然后就可以执行这个方法并把返回值返回出去。这里的IMP类型就是要调用方法的C语言实现，也就是一个C函数指针。
 
##2.id
 
id被定义在objc.h中：

{% hl %}
 
typedef struct objc_object {
    Class isa;
} *id;
 
{% endhl %}

可以看到id就是objc_object结构体，它包含了一个isa指针指向类的描述信息，这样的话id就可以用来动态描述类的类型了。

id的作用类似于Javascript中的var，也就是说用id关键字声明的变量在编译时并不知道其具体类型，而是在运行时决定。因为有id关键字的存在，所以Objective-C就不是单纯的面向对象语言，而是面向对象语言和动态语言的混合体，从这点来看Objective-C倒跟C#有点像。

##参考资料
 
[1] [Concepts in Objective-C Programming: Object Modeling](https://developer.apple.com/library/ios/documentation/general/conceptual/CocoaEncyclopedia/ObjectModeling/ObjectModeling.html)
[2] [Objective-C Wiki](http://en.wikipedia.org/wiki/Objective-C)
[3] [Objective-C Runtime Programming Guide](https://developer.apple.com/library/mac/documentation/cocoa/conceptual/ObjCRuntimeGuide/Articles/ocrtHowMessagingWorks.html)