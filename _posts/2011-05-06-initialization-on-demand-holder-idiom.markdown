---
layout: post
title: "Initialization-on-demand holder idiom"
date: 2011-05-06 20:04
---
在软件开发中，需求持有者的初始化指的是一种延迟加载的单例设计模式。它可以在单线程和多线程环境中实现，但是在多线程环境中需要多加小心。

这个实现版本兼顾性能和线程安全。Bill Pugh的最初的版本是在Steve Quirk的工作基础上改进而来，把LazyHolder.INSTANCE的作用域减小为了private final。

{% hl %}
public class Something {
  private Something() {
  }
 
  private static class LazyHolder {
    private static final Something something = new Something();
  }
 
  public static Something getInstance() {
    return LazyHolder.something;
  }
}
{% endhl %}

## 工作原理

实现是根据详细描述的JVM初始化执行阶段的文档，具体参见Java Language Specification(JLS)的[12.4](http://docs.oracle.com/javase/specs/jls/se7/html/jls-12.html#jls-12.4)节。

当JVM加载Something类的时候，它就要被初始化。因为它没有静态变量需要初始化，所以初始化就变得很简单。静态内部类LazyHolder直到JVM决定要执行它时才会被初始化。LazyHolder只有在getInstance方法被调用时才会被执行，并且在第一次执行的时候初始化LazyHolder类。LazyHolder的初始化使静态实例变量something通过私有构造方法被初始化。JLS保证了类的初始化阶段是顺序执行的：单线程， getInstance方法的加载和初始化不需要同步。又因为初始化阶段是串行地写something变量，所以以后的getInstance的并发调用会返回相同的正确初始化后的something类而不会引起额外的同步开销。

## 适用情况

如果类的初始化是昂贵并且不是线程安全的情况下可以使用这个模式。这个模式的关键是安全地解决了单例模式的多线程同步开销。

## 不适用情况

如果在Something类的构造方法中有错误代码的情况下使用这个模式会引起无法预料的结果。例如在构造方法中建立外部连接，但是出错了，这种情况下程序会进入到无法恢复的状态中去。这是因为在第一次调用的时候，静态内部类LazyHolder已经被初始化并且被JVM加载了，这时候静态实例变量INSTANCE已经被初始化为null (因为私有构造方法抛出了异常)。任何以后的getInstance调用会引起NoClassDefFoundError错误。

原文地址： [Initialization-on-demand holder idiom](http://en.wikipedia.org/wiki/Initialization-on-demand_holder_idiom)