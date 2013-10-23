---
layout: post
title: "Goroutine源码分析"
date: 2013-10-22 19:55
---
Go语言虽然从诞生到现在已经三年多了，但是从来没有像今年这样火热过，很多公司都开始用Go来开发自己的应用了。我自己在体验过Go以后也喜欢上了这门语言，其中很大一个原因就是goroutine。为了更深入地理解goroutine，接下来就从源码角度分析一下goroutine的实现原理。

首先我们来看看什么是goroutine，在[官方文档](http://golang.org/doc/effective_go.html)里是这么说的：

> They're called goroutines because the existing terms—threads, coroutines, processes, and so on—convey inaccurate connotations. A goroutine has a simple model: it is a function executing concurrently with other goroutines in the same address space. It is lightweight, costing little more than the allocation of stack space. And the stacks start small, so they are cheap, and grow by allocating (and freeing) heap storage as required.

> Goroutines are multiplexed onto multiple OS threads so if one should block, such as while waiting for I/O, others continue to run. Their design hides many of the complexities of thread creation and management.

> Prefix a function or method call with the go keyword to run the call in a new goroutine. When the call completes, the goroutine exits, silently. (The effect is similar to the Unix shell's & notation for running a command in the background.)

用一句话概括goroutine就是： goroutine是轻量级的，开销低的，对应到多个操作系统线程上去执行的『线程』。文档还是说的比较抽象，看来只有看源代码了，打开goroutine的[源代码](http://golang.org/src/pkg/runtime/proc.c)，我们可以看到这样一段注释：

{% hl %}

The main concepts are:

G - goroutine.

M - worker thread, or machine.

P - processor, a resource that is required to execute Go code. M must have an associated P to execute Go code, however it can be blocked or in a syscall w/o an associated P.

{% endhl %}

从这个注释我们可以知道，与goroutine相关的有两个概念： M(工作线程)和P(CPU)，先记住这个概念然后继续看代码。G就是goroutine，打开G的[源代码](http://golang.org/src/pkg/runtime/runtime.h)，我们可以看到G就是一个结构体：

{% hl %}

struct	G
{
    uintptr	stackguard;	// cannot move - also known to linker, libmach, runtime/cgo
    uintptr	stackbase;	// cannot move - also known to libmach, runtime/cgo
    Defer*	defer;
    Panic*	panic;
    Gobuf	sched;
    uintptr	gcstack;		// if status==Gsyscall, gcstack = stackbase to use during gc
    uintptr	gcsp;		// if status==Gsyscall, gcsp = sched.sp to use during gc
    byte*	gcpc;		// if status==Gsyscall, gcpc = sched.pc to use during gc
    uintptr	gcguard;		// if status==Gsyscall, gcguard = stackguard to use during gc
    uintptr	stack0;
    FuncVal*	fnstart;		// initial function
    G*	alllink;	// on allg
    void*	param;		// passed parameter on wakeup
    int16	status;
    int64	goid;
    uint32	selgen;		// valid sudog pointer
    int8*	waitreason;	// if status==Gwaiting
    G*	schedlink;
    bool	ispanic;
    bool	issystem;	// do not output in stack dump
    bool	isbackground;	// ignore in deadlock detector
    bool	blockingsyscall;	// hint that the next syscall will block
    int8	raceignore;	// ignore race detection events
    M*	m;		// for debuggers, but offset not hard-coded
    M*	lockedm;
    int32	sig;
    int32	writenbuf;
    byte*	writebuf;
    DeferChunk	*dchunk;
    DeferChunk	*dchunknext;
    uintptr	sigcode0;
    uintptr	sigcode1;
    uintptr	sigpc;
    uintptr	gopc;	// pc of go statement that created this goroutine
    uintptr	racectx;
    uintptr	end[];
};

{% endhl %}

其中每个成员变量的作用没有必要去深究，现在回到之前的源文件，找到创建G的代码：
 
{% hl %}
 
// Allocate a new g, with a stack big enough for stacksize bytes.
G*
runtime·malg(int32 stacksize)
{
	G *newg;
	byte *stk;
	
	if(StackTop < sizeof(Stktop)) {
		runtime·printf("runtime: SizeofStktop=%d, should be >=%d\n", (int32)StackTop, (int32)sizeof(Stktop));
		runtime·throw("runtime: bad stack.h");
	}
	
	newg = runtime·malloc(sizeof(G));
	if(stacksize >= 0) {
		if(g == m->g0) {
			// running on scheduler stack already.
			stk = runtime·stackalloc(StackSystem + stacksize);
		} else {
			// have to call stackalloc on scheduler stack.
			g->param = (void*)(StackSystem + stacksize);
			runtime·mcall(mstackalloc);
			stk = g->param;
			g->param = nil;
		}
		newg->stack0 = (uintptr)stk;
		newg->stackguard = (uintptr)stk + StackGuard;
		newg->stackbase = (uintptr)stk + StackSystem + stacksize - sizeof(Stktop);
		runtime·memclr((byte*)newg->stackbase, sizeof(Stktop));
	}
	return newg;
}

{% endhl %}
 
可以看到G是在 `newg = runtime·malloc(sizeof(G));` 这行被创建的。具体来说，如果G不大于32kB的话就会直接在M的cache中(也就是stack)创建，否则G就会在堆上创建。因为G是被M创建的，所以goroutine就不是操作系统级别的线程，而可以看作用户级别的线程，这也就使goroutine的线程切换的开销比操作系统级线程小的多，再加上每个goroutine在创建之初只拥有一个4k大小的栈空间，运行中随着函数的调用，如果发现栈空间不够当前函数使用时则临时从堆上分配出另一段空间用作当前正在执行的函数以及更深层次的函数调用的栈，这样goroutine在执行时所拥有的栈可能由多段地址不连续的空间组成，这就是Go中使用的split stacks或segmented stacks技术，从而达到在一个进程中使用成千上万个goroutine的目的。
 
但是很容易想到这种设计存在的缺陷，那就是有可能出现线程利用不充分造成的性能问题。比如把10个G平均分配到2个M上去执行，那么很有可能M1已经执行完了在等待，但是M2还在执行，这就造成了M1资源的浪费。Go为了解决这个问题，实现了一个语言级别上的调度器，当发生上述情况时，M2就会去『偷』M1还没有执行完的G的一半，这就保证了每个M都被充分利用，从而提高并发的性能。

与Go不同的是，Java中的Thread类就是操作系统级别的线程，它的执行必须要靠操作系统来调度来完成，这也就注定了Goroutine比Java Thread高效地多的多。

## 参考资料

* [Effective Go](http://golang.org/doc/effective_go.html)  
* [goroutine背后的系统知识](http://www.sizeofvoid.net/goroutine-under-the-hood/)  
* [Why is a Goroutine’s stack infinite](http://dave.cheney.net/2013/06/02/why-is-a-goroutines-stack-infinite)  
