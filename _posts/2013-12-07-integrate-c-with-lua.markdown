---
layout: post
title: "Lua和C的结合"
date: 2013-12-07 12:04
---
我们在用C写程序的时候，很多情况下需要用到List，Map等集合，但是C是不原生支持这些数据结构的。碰到这种情况的话，要么自己实现一套API，要么就用别人写好的现成的类库。但是大多数情况下现有类库的API使用起来非常不舒服，自己写呢又重复造轮子，那有没有其他的办法呢？答案是肯定的。我们可以用Lua这个嵌入式脚本语言与C搭配使用，来弥补C这个古老语言的很多先天性的不足。
 
##0.什么是Lua
 
引用Lua官网上的解释：
 
>Lua is a powerful, fast, lightweight, embeddable scripting language.
 
>Lua combines simple procedural syntax with powerful data description constructs based on associative arrays and extensible semantics. Lua is dynamically typed, runs by interpreting bytecode for a register-based virtual machine, and has automatic memory management with incremental garbage collection, making it ideal for configuration, scripting, and rapid prototyping.
 
Lua和Ruby，Python一样都是脚本语言，但是Lua还有其他脚本语言不具备的特性：Lua还是嵌入式的脚本语言。Lua脚本可以很容易的被 C/C++ 代码调用，也可以反过来调用C/C++的函数，这使得Lua在应用程序中可以被广泛应用。Lua由标准C编写而成，代码简洁优美，几乎在所有操作系统和平台上都可以编译，运行。一个完整的Lua解释器不过200k，在目前所有脚本引擎中，Lua的速度是最快的。
 
而且，Lua还有一个[LuaJIT](http://luajit.org/index.html)的项目，可以提供在特定平台上的即时编译功能，这将给Lua带来更加优秀的性能。
 
##1.在C中执行Lua脚本

首先是C代码：

{% hl %}
 
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
 
int main(){
 
	lua_State *L = luaL_newstate();  /* opens Lua */
	luaL_openlibs(L);   /* opens the standard libraries */
   
	luaL_dofile(L,"test.lua"); /* runs Lua script */
   
	lua_close(L);     
	return 0;
 
}

{% endhl %}

然后是Lua脚本：
 
{% hl %}
 
print("This is executed from C")
 
{% endhl %}

最后编译运行：

{% hl %}

$ gcc -o test test.c -I/usr/local/Cellar/lua/5.1.5/include -llua
$ ./test
This is executed from C

{% endhl %}

现在我们来详细看这段代码。首先我们要引入三个头文件`lua.h`，`lauxlib.h`和`lualib.h`。`lua.h`中定义的是最基础的API，`lauxlib.h`中的函数都以`luaL_`开头，他们是比基础API更抽象的函数，`lualib.h`中定义了打开标准类库的API，比如`luaL_openlibs(L)`。

程序开始用`luaL_newstate()`函数创建一个`lua_State`。`lua_State`中保存了Lua运行时的所有的状态信息(比如变量的值等)，并且所有的Lua的C的API都有一个`lua_newstate`指针的参数。`luaL_newstate`函数会创建一个全新的Lua运行时状态，其中没有任何预先定义好的函数(包括最基本的print函数)。如果需要试用标准类库的话，只要调用`luaL_openlibs(L)`函数就打开标准类库就可以了。标准类库被分别封装在不同的包中，当你需要使用的时候再引入到代码中，这样做的好处是可以使Lua尽可能的小(嵌入式语言必须要小)，从而可以方便嵌入到其他语言中去。当Lua运行时状态和标准类库都准备完成后，就可以调用`luaL_dofile(L,"test.lua")`函数来执行Lua脚本。运行结束后，需要调用`lua_close(L)`来关闭Lua运行时状态。


##2.Lua和C的数据交换

当我们在C中调用Lua的API的时候(比如把变量保存在Lua的数据结构中)，Lua需要读取并保存C的数据。但问题是C和Lua是两种不同的语言：前者是静态的，手动管理内存的语言；而后者是动态的，自动管理内存的语言，所以Lua在运行的时候维护了一个自己的stack用来和C做数据交换。这个stack中的每个槽可以是任意的Lua类型，当你需要从Lua中请求一个值而调用Lua的API的时候，这个值会被push到stack中去；当你想传值给Lua的时候，你必须先把这个值push到stack中去，然后再调用Lua的API。默认情况下Lua的stack有20格槽可以使用，任何时候push值到stack都必须保证stack是有可用空间的，所以如果程序有可能会使stack溢出的时候就需要调用`lua_checkstack`函数来检查stack的空间是否还有可用空间。

##3.在C中使用Lua的table

Lua中的table是非常好用的数据结构，有点像Java里的Map。

C代码：

{% hl %}

#include <stdio.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

int main(){

	lua_State *L = luaL_newstate();  /* opens Lua */
	luaL_openlibs(L);   /* opens the standard libraries */

	lua_newtable(L);    /* creates a new table */
	lua_pushstring(L, "test");
	lua_pushstring(L, "Hello World");
	lua_settable(L, -3);   /* t["test"] = "Hello World" */

	lua_pushstring(L, "test");
	lua_gettable(L, -2);   /* pushes t["test"] onto the stack top */
	const char *str = lua_tostring(L, -1);
	printf("%s", str);

	lua_close(L);
	return 0;

}

{% endhl %}

编译运行：

{% hl %}

$ gcc -o test test.c -I/usr/local/Cellar/lua/5.1.5/include -llua
$ ./test
Hello World

{% endhl %}

在C中试用Lua的table还是非常简单的，最主要的就是对stack的pop和push操作。上面这段代码首先会创建一个空的table并且push到stack中，然后再push两格字符串(一个作为key，一个作为value)到stack中。注意，Lua的下标是从1开始的，所以在调用`lua_settable`函数的时候，table的index值就是-3(从上往下数的index是负数)。`lua_settable`函数调用完成后会pop掉key和value，这样的话stack只剩下table，要取table里的值必须在push一遍key值，这样我们就能取到对应的value值了。

##4.总结

如今Lua已经越来越多地被应用到与类C语言(C/C++/Objective C)配合开发，看重就是Lua小巧，速度快，动态语言的特性。使用Lua就可以为应用程序提供灵活的扩展和定制功能，极大地提高了应用程序的扩展性。


##参考文档

[1] [Lua 5.1 Reference Manual](http://www.lua.org/manual/5.1/manual.html)