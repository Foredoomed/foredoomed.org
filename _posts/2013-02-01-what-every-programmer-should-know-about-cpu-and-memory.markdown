---
layout: post
title: "每个程序员都应该知道的关于CPU和内存的那些事"
date: 2013-02-01 21:35
---
## volatile做了些什么

先来看下面的测试代码：

{% hl %}

  private static long value1;
  private static volatile long value2;

  public static void increment1() {
    while (value1 < 100000000L) {
      value1++;
    }
  }

  public static void increment2() {
    while (value2 < 100000000L) {
      value2++;
    }
  }

  public static void main(String[] args) {
    long start1 = System.currentTimeMillis();
    increment1();
    long end1 = System.currentTimeMillis();
    System.out.println("increment1 cost: " + (end1 - start1));
    
    long start2 = System.currentTimeMillis();
    increment2();
    long end2 = System.currentTimeMillis();
    System.out.println("increment2 cost: " + (end2 - start2));

  }

{% endhl %}

在我的笔记本上(i5 2.40 GHz)上输出的结果是：

{% hl %}

increment1 cost: 55
increment2 cost: 817

{% endhl %}

为什么用了volatile关键字却比没有用的慢呢？要搞清楚这个问题，我们先要弄明白CPU的结构，如下图所示：

![cachehierarchy](http://i1256.photobucket.com/albums/ii494/Foredoomed/cachehierarchy_zpsa66e1ba7.jpg "cachehierarchy")

我们可以看到CPU的每个核心都有自己独享的一个64KB的L1缓存(包括32KB的L1 Data和32KB的L1 Instruction缓存),一个256KB的L2缓存，还有一个共享的4-12MB的L3缓存。上面这个图就是Intel的[Nehalem](http://en.wikipedia.org/wiki/Nehalem_\(microarchitecture\) "Nehalem")微处理器架构，现在这个架构被广泛用于Intel的i3,i5,i7系列CPU中。

回到volatile上面来，先来分析下没有volatile时的程序执行情况。首先程序会在内存中分配一段空间给变量value1，然后再复制一份拷贝到寄存器中，运算得到的结果保存在缓存中。

再来看有valotile修饰时的情况。在Java内存模型(JMM)上对于volatile是这么描述的：

>Volatile fields are special fields which are used for communicating state between threads. Each read of a volatile will see the last write to that volatile by any thread; in effect, they are designated by the programmer as fields for which it is never acceptable to see a "stale" value as a result of caching or reordering. The compiler and runtime are prohibited from allocating them in registers. They must also ensure that after they are written, they are flushed out of the cache to main memory, so they can immediately become visible to other threads. Similarly, before a volatile field is read, the cache must be invalidated so that the value in main memory, not the local processor cache, is the one seen. 

这段话清楚地说明了被volatile修饰的变量不能被分配到寄存器中去，在写之后必须写回内存，读值的时候要直接从内存中去读而不是缓存。好了，现在我们知道了test1和test2方法的不同之处在于：test2需要频繁地读写内存，而test1可以直接读写缓存。

所以缓存和内存的延迟时间造成了两者运行时间的差异。下图给出了缓存和内存的延迟时间：

![microarchitecture](http://i1256.photobucket.com/albums/ii494/Foredoomed/ScreenShot2013-02-02at64845PM_zpsd761ac16.png "microarchitecture")

而Google研究主管[Peter Norvig](http://norvig.com/ "Peter Norvig")则给出过一些具体的计算机操作所需要的时间：

<table border="1" cellpadding="2" cellspacing="2">
<tbody><tr><td>execute typical instruction</td><td align="right"> 1/1,000,000,000 sec = 1 nanosec
</td></tr><tr><td>fetch from L1 cache memory</td><td align="right"> 0.5 nanosec
</td></tr><tr><td>branch misprediction</td><td align="right"> 5 nanosec
</td></tr><tr><td>fetch from L2 cache memory</td><td align="right"> 7 nanosec
</td></tr><tr><td>Mutex lock/unlock</td><td align="right"> 25 nanosec
</td></tr><tr><td>fetch from main memory</td><td align="right"> 100 nanosec 
</td></tr><tr><td>send 2K bytes over 1Gbps network</td><td align="right"> 20,000 nanosec
</td></tr><tr><td>read 1MB sequentially from memory</td><td align="right"> 250,000 nanosec
</td></tr><tr><td>fetch from new disk location (seek)</td><td align="right"> 8,000,000 nanosec
</td></tr><tr><td>read 1MB sequentially from disk</td><td align="right"> 20,000,000 nanosec
</td></tr><tr><td>send packet US to Europe and back</td><td align="right"> 150 milliseconds = 150,000,000 nanosec
</td></tr></tbody></table>

对比缓存和内存的延迟时间，我们就知道有volatile的情况肯定比没有volatile的情况耗时更多，这也应证了之前的实验结果。


## 二维数组的遍历

还是先来看代码：

{% hl %}

int array[SIZE][SIZE];

public void test1(){
  for (int col = 0; col < SIZE; col++)
    for (int row = 0; row < SIZE; row++)
      array[row][col] = f(row, col);
}

public void test2(){
  for (int row = 0; row < SIZE; row++)
    for (int col = 0; col < SIZE; col++)
      array[row][col] = f(row, col);
}

{% endhl %}

test1还是test2跑得更快？要解决这个问题，我们需要对**cache line**有一个了解。

缓存是被分成大小相等的多个区块，这些大小相等的区块就叫做cache line，典型的cache line大小从32字节到256字节不等。所以说cache line是数据在内存和缓存或者各级缓存之间传输的最小区块。因为缓存比内存小得多，就需要有一种技术来帮助处理器在缓存中查找数据，而且还包括对保存在缓存中的实际内存地址的验证。

好了现在回头来看上面的代码。test1方法是先循环列再循环行，在每一次的外层循环中会读取每一行的特定的一列，以8*8的二维数组为例：

![Inefficient Loop Nesting](http://i1256.photobucket.com/albums/ii494/Foredoomed/inefficient_loop_nesting_zps8d0f2e95.png "Inefficient Loop Nesting")

首先数组在内存中是按行存储的，也就是每一行的尾地址和下一行的起始地址是连续存储在内存中的。虽然一行cache line可以保存16个数，但是因为先循环数组的列再循环数组的行，所以每次内循环都要读取数组每一行的特定一列的值，而这些列在内存中所在的位置是不连续的，所以当每次从内存中读取数到缓存中去时也必须保存到新的cache line中去。这样一来，cache line就不能被充分利用，而且当数组的列的长度大于cache line的数量后会造成cache line的重复load，性能就会变差。

相比test1方法的先循环列再循环行，test2方法是先循环行再循环列，缓存使用情况可以用下图表示：

![Efficient Loop Nesting](http://i1256.photobucket.com/albums/ii494/Foredoomed/efficient_loop_nesting_zps68f73428.png "Efficient Loop Nesting")

很明显因为列地址连续，所以cache line就被充分利用，从而提高了性能。

## Cache Coherence和MESI协议

在单核处理器中每个cache line有2个标志：dirty和valid，他们很好的描述了cache和内存之间的数据关系(数据是否有效，数据是否被修改)。而在多核处理器中，多个核会L3共享cache中共享一些数据，所以MESI协议就包含了描述共享的状态。

在MESI协议中，每个Cache line有4个状态，所以可以用2个bit表示。它们分别是：

<table border="1" cellpadding="2" cellspacing="2"><tbody> <tr><td align="center">状态</td><td align="center">描述</td></tr><tr><td>M(Modified)</td><td>这行数据有效，数据被修改了，和内存中的数据不一致，数据只存在于本Cache中。</td></tr><tr><td>E(Exclusive)</td><td>这行数据有效，数据和内存中的数据一致，数据只存在于本Cache中。</td></tr><tr><td>S(Shared)</td><td>这行数据有效，数据和内存中的数据一致，数据存在于多个Cache中。</td></tr><tr><td>I(Invalid)</td><td>这行数据无效</td></tr></tbody></table>

MESI协议状态可以转换，即每个cache line所处的状态根据本核和其它核的读写操作在4个状态间进行转换。具体的状态转换可由下图表示：

![MESI](http://i1256.photobucket.com/albums/ii494/Foredoomed/mesi_zpsfdbedd50.png "MESI")

在上图中，Local Read表示本内核读本Cache中的值，Local Write表示本内核写本Cache中的值，Remote Read表示其它内核读其它Cache中的值，Remote Write表示其它内核写其它Cache中的值。

## False Sharing

缓存是以cache line为单位存储的，而且是2的整数幂个连续字节，一般为32-256个字节。最常见的cache line大小是64个字节。当多线程修改互相独立的变量时，如果这些变量共享同一个cache line时，就会无意中对性能产生影响。所以为了确定互相独立的变量是否共享了同一个cache line，就需要了解内存布局，或找个工具告诉我们。[Intel VTune](http://software.intel.com/en-us/intel-vtune-amplifier-xe "Intel VTune")就是这样一个分析工具。

![false sharing](http://i1256.photobucket.com/albums/ii494/Foredoomed/cache-line_zps4024b14d.png "false sharing")

上图清楚地说明了伪共享的问题。在核心1上运行的线程想更新变量X，同时核心2上的线程想要更新变量Y。不幸的是，这两个变量在同一个cache line中。每个线程都要去竞争cache line的所有权来更新变量。如果核心1获得了所有权将会使核心2中对应的cache line失效。当核心2获得了所有权并执行更新操作后，核心1就要使自己对应的cache line失效。这会来来回回的经过L3缓存，大大影响了性能。如果互相竞争的核心位于不同的插槽，就要额外横跨插槽连接，问题可能更加严重。

对于HotSpot JVM来说，基本数据类型和对象在内存中被分配的大小如下图所示：

<table border="1" cellpadding="2" cellspacing="2"><tbody> <tr><td align="center">数据类型</td><td align="center">空间(字节)</td></tr><tr><td>byte</td><td align="right">1</td></tr><tr><td>char</td><td align="right">2</td></tr><tr><td>short</td><td align="right">2</td></tr><tr><td>int</td><td align="right">4</td></tr><tr><td>float</td><td align="right">4</td></tr><tr><td>long</td><td align="right">8</td></tr><tr><td>double</td><td align="right">8</td></tr><tr><td>reference</td><td>4(32位)/8(64位)</td></tr></tbody></table>

为了防止false sharing的发生，我们可以通过把整个cache line填充满来实现。考虑到典型的cache line的大小为64字节，所以如果是一个对象的时候，我们就可以用7个long类型来填充cache line。

{% hl %}

public final class FalseSharing implements Runnable {
  public final static int NUM_THREADS = 4; // change
  public final static long ITERATIONS = 500L * 1000L * 1000L;
  private final int arrayIndex;
  
  private static VolatileLong[] longs = new VolatileLong[NUM_THREADS];
  
  static {
    for (int i = 0; i < longs.length; i++) {
      longs[i] = new VolatileLong();
    }
  }
  
  public FalseSharing(final int arrayIndex) {
    this.arrayIndex = arrayIndex;
  }
  
  public static void main(final String[] args) throws Exception {
    final long start = System.nanoTime();
    runTest();
    System.out.println("duration = " + (System.nanoTime() - start));
  }
  
  private static void runTest() throws InterruptedException {
    Thread[] threads = new Thread[NUM_THREADS];
    
    for (int i = 0; i < threads.length; i++) {
      threads[i] = new Thread(new FalseSharing(i));
    }
  
    for (Thread t : threads) {
      t.start();
    }
  
    for (Thread t : threads) {
      t.join();
    }
  }
  
  public void run() {
    long i = ITERATIONS + 1;
      while (0 != --i) {
        longs[arrayIndex].value = i;
      }
  }
  
  public final static class VolatileLong {
    public volatile long value = 0L;
    public long p1, p2, p3, p4, p5, p6; // comment out
  }
}

{% endhl %}

运行上面的代码，增加线程数以及添加/移除对cache line的填充，结果如下：

![result](http://i1256.photobucket.com/albums/ii494/Foredoomed/duration_zps9bd162ec.png "result")

## 内存屏障

编译器在编译代码时会对源代码进行优化，其中之一就是代码重排。由于单核处理器能确保与「顺序执行」相同的一致性，所以在单核处理器上并不需要专门做什么处理就可以保证正确的执行顺序。但在多核处理器上通常需要使用内存屏障指令来确保这种一致性。

几乎所有的处理器至少支持一种粗粒度的屏障指令，通常被称为「栅栏（Fence）」，它保证在栅栏前初始化的load和store指令，能够严格有序的在栅栏后的load和store指令之前执行。无论在何种处理器上，这几乎都是最耗时的操作之一（与原子指令差不多，甚至更消耗资源），所以大部分处理器支持更细粒度的屏障指令。

下面是一些屏障指令的通常分类：

### LoadLoad

序列：Load1,Loadload,Load2  
确保Load1所要读入的数据能够在被Load2和后续的load指令访问前读入。通常能执行预加载指令或/和支持乱序处理的处理器中需要显式声明Loadload屏障，因为在这些处理器中正在等待的加载指令能够绕过正在等待存储的指令。 而对于总是能保证处理顺序的处理器上，设置该屏障相当于无操作。

### StoreStore

序列：Store1,StoreStore,Store2  
确保Store1的数据在Store2以及后续Store指令操作相关数据之前对其它处理器可见（例如向主存刷新数据）。通常情况下，如果处理器不能保证从写缓冲或/和缓存向其它处理器和主存中按顺序刷新数据，那么它需要使用StoreStore屏障。

### LoadStore

序列：Load1,LoadStore,Store2  
确保Load1的数据在Store2和后续Store指令被刷新之前读取。在Store指令可以越过load指令的乱序处理器上需要使用LoadStore屏障。

### StoreLoad

序列：Store1,StoreLoad,Load2  
确保Store1的数据在被Load2和后续的Load指令读取之前对其他处理器可见。StoreLoad屏障可以防止一个后续的load指令 不正确的使用了Store1的数据，而不是另一个处理器在相同内存位置写入一个新数据。

## 参考资料

* [Intel Nehalem Microarchitecture](http://en.wikipedia.org/wiki/Nehalem_\(microarchitecture\) "Intel Nehalem Microarchitecture")
* [CPU Cache](http://en.wikipedia.org/wiki/CPU_cache "cpu cache")
* [false sharing](http://mechanical-sympathy.blogspot.com/2011/07/false-sharing.html "false sharing")
* [JSR-133 Cookbook](http://gee.cs.oswego.edu/dl/jmm/cookbook.html "JSR-133 Cookbook")

