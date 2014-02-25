---
layout: post
title: Objective-C中Block的实现
date: 2014-02-25 19:36
---
Block是苹果公司在OS X 10.6和iOS 4之后引入的Objective-C语言的扩展。由于Block的出现使得Objective-C拥有了编写类似函数式语言中闭包的能力，现在在许多开源类库中都可以看到Block被用作回调函数的情况。因为Objective-C是用C语言实现的，而C并不原生支持闭包，所以我感兴趣的是Block的底层是怎么实现的。
 
在Clang的[Block Implementation Specification](http://clang.llvm.org/docs/Block-ABI-Apple.html)文档中可以找到编译后的Block的结构：
 
{% hl %}
 
struct Block_literal_1 {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
    unsigned long int reserved;         // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};
 
{% endhl %}
 
可以看到在Block结构体中含有isa指针，这就证明了Block其实就是对象，并具有一般对象的所有功能。这个isa指针被初始化为`_NSConcreteStackBlock`或者`_NSConcreteGlobalBlock`类的地址。在没有开启ARC的情况下，如果Block中包含有局部变量则isa被初始化为前者，否则就被初始化为后者。而当ARC开启后，如果Block中包含有局部变量则isa被初始化为`_NSConcreteMallocBlock`，否则就被初始化为`_NSConcreteGlobalBlock`。invoke是一个函数指针，它指向的是Block被转换成函数的地址。最后的imported variables部分是Block需要访问的外部的局部变量，他们在编译就会被拷贝到Block中，这样一来Block就是成为一个闭包了。
 
在Clang的文档上有个Block的例子：
 
{% hl %}
 
^ { printf("hello world\n"); }
 
{% endhl %}
 
上面这个Block会被编译成：
 
{% hl %}
 
struct __block_literal_1 {
    void *isa;
    int flags;
    int reserved;
    void (*invoke)(struct __block_literal_1 *);
    struct __block_descriptor_1 *descriptor;
};
 
void __block_invoke_1(struct __block_literal_1 *_block) {
    printf("hello world\n");
}
 
static struct __block_descriptor_1 {
    unsigned long int reserved;
    unsigned long int Block_size;
} __block_descriptor_1 = { 0, sizeof(struct __block_literal_1), __block_invoke_1 };
 
{% endhl %}
 
最终Block就会变成：
 
{% hl %}
 
struct __block_literal_1 _block_literal = {
     &_NSConcreteStackBlock,
     (1<<29), <uninitialized>,
     __block_invoke_1,
     &__block_descriptor_1
};
 
{% endhl %}

##参考资料

[1] [Objective-C Wiki](http://en.wikipedia.org/wiki/Objective-C)  
[2] [Block Implementation Specification](http://clang.llvm.org/docs/Block-ABI-Apple.html)