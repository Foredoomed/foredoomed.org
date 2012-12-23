---
layout: post
title: "浏览器是如何工作的(十)"
date: 2011-12-16 00:26
---
## 6 绘制

在绘制阶段会遍历渲染树和调用renderer的paint方法来把他们的内容显示在屏幕上。绘制使用的是UI基础组件。

### 6.1 全局和增量

像布局一样，可以全局绘(绘制整个渲染树)，也可以是增量绘制。在增量绘制中，一部分renderer的变化不会影响这棵渲染树。变化过的renderer会使它在屏幕上的矩形区域无效，这就会造成OS把它当作“脏区域”(dirty region)并且生成paint事件。OS会聪明地把多个脏区域合并成一个。在Chrome中则更复杂一点，因为renderer不是在主进程中，而是在其他进程中。Chrome模拟OS行为并且扩展它们，表现层监听这些事件而且把消息代理给渲染树的根元素。遍历渲染树直到遇见相关的renderer，渲染树重新绘制自己(经常连同它的孩子节点)。

### 6.2 绘制顺序

CSS2的规范中规定了绘制的顺序。这个顺序实际上就是元素在上下文中堆积的顺序。因为是从后往前绘制的，所以这个顺序会影响绘制。renderer的堆积顺序是：

1. background color
2. background image
3. border
4. children
5. outline

### 6.3 Firefox的显示列表

Firefox会再次遍历渲染树，然后构造一个已经绘制的矩形区域的显示列表。其中包含矩形区域相关的renderer，从右往左的绘制顺序(背景，边框等)。这种方式只需要遍历一次渲染树就可以重新绘制(所有背景，再所有图片，再所有边框等)。

Firefox通过不把hidden的元素加入到列表中来优化这个过程。

### 6.4 Webkit的矩形存储

在重新绘制之前，webkit把旧的矩形保存为一个bitmap，然后只重新绘制新旧矩形的不同之处。

## 7 动态变化

对应一个修改，浏览器会做尽可能少的动作，所以改变元素的颜色只会重新绘制这个元素。元素位置的改变会使元素重新布局和绘制，包括它的孩子和同辈元素。添加一个DOM节点会导致重新布局和绘制这个节点，主要的变化，比如改变html元素的字体大小，会导致缓存失效，重新布局和绘制整棵渲染树。

## 8 渲染引擎的线程

渲染引擎是单线程的，除了网络操作，大多数情况下是单线程的。在Firefox和Safari里，渲染线程是浏览器的主线程，但是在Chrome里它则是标签页进程的主线程。

网络操作可以被多个线程并行执行，并行连接的数量是限定的(一般是2到6个连接，例如Firefox 3采用的是6个连接)。

### 8.1 事件循环

浏览器的主线程是一个事件循环，而且这个循环是无限的来保持进程能一直存活下去。它等待事件(比如布局和绘制事件)的到来，然后处理他们。下面是Firefox的主事件循环代码：

{% hl %}
while (!mExiting)
    NS_ProcessNextEvent(thread);
{% endhl %}

## 9 CSS2的视觉模型

### 9.1 画布(canvas)

根据CSS2的规范，画布是指：格式化结构被渲染的空间，也就是浏览器绘制内容的地方。画布在空间的任意维度上都是无限的，但是浏览器会在viewport的维度上选择一个初始宽度。

根据[z-index](www.w3.org/TR/CSS2/zindex.html "z-index")上所说，如果一个画布内包含了另一个画布的话，那么它内部的画布就会边透明；而如果没有包含其他画布的话，浏览器会给它一个浏览器定义的颜色。

### 9.2 CSS的盒子模型(box model)

CSS的盒子模型描述的是在文档树中为元素生成的矩形盒子，并且根据视觉格式模型被展现出来。

每个盒子有一个内容区域(比如：文字，图片等)和可选的padding，border以及margin区域。

![box model](http://i1256.photobucket.com/albums/ii494/Foredoomed/boxmodel_zps5e97b08d.jpg "box model")

每个节点都会生成0到n个这样的盒子。所有的元素都有一个display属性，这个属性决定了要生成盒子的类型。例如：

block  - generates a block box.
inline - generates one or more inline boxes.
none - no box is generated.

默认的盒子是inline类型的，但是浏览器自带的样式标会设置成其他默认值。例如：div元素的display默认值是block。你可以在[这里](www.w3.org/TR/CSS2/sample.html)找到默认样式表的例子。

### 9.3 确定scheme的位置

有三种类型的scheme：

1. 普通： 对象是根据它在文档中的位置来确定位置的，也就是说它在渲染树中的位置就好像它在DOM树中的位置，然后根据它的盒子类型和维度展现出来。
2. 浮动： 对象一开始是普通类型，然后尽可能地往左边或右边移动。
3. 绝对： 对象在渲染树中的位置和它在DOM树中的位置不同。

scheme的位置是通过设置position属性和float属性来确定的。

* 静态和相对的值生成普通流
* 绝对和固定的值生成绝对的位置

在静态位置确定过程中，position没有被定义，而且使用默认值，在其他scheme里，开发者指定了position(top,bottom,left,right)。

盒子展现的方式是由以下条件决定的：

* 盒子的类型
* 盒子的维度
* scheme的位置
* 外部信息(比如：图片大小和屏幕尺寸)

### 9.4 盒子的类型

Block：在浏览器窗口中有自己的矩形区域

![block box](http://i1256.photobucket.com/albums/ii494/Foredoomed/blockbox_zpsafde709e.png "block box")

Inline：没有自己的block，但是被其他block包含

![inline box](http://i1256.photobucket.com/albums/ii494/Foredoomed/inlinebox_zps5e116bc8.png "inline box")

Block垂直方向上一个排列，Inline在水平方向上排列

![block and inline formatting](http://i1256.photobucket.com/albums/ii494/Foredoomed/blockandinlineformatting_zps4f77a12c.png "block and inline formatting")

Inline盒子被放在一行行中，所以又叫”line boxes”。行的高度至少要和最高的盒子一样，但是可以更高。当盒子和基准行(baseline)对齐时，意味着元素的底部和其他盒子不是底部的某个点对齐。为了防止容器的宽度不够，inline的盒子会被放在多行中，这一般发生在有段落的情况下。

![lines](http://i1256.photobucket.com/albums/ii494/Foredoomed/lines_zpsb36ddb74.png "lines")

### 9.5 确定位置

#### 9.5.1 相对盒子

相对位置是：先像通常一样放置，然后根据差异移动。

![relative positioning](http://i1256.photobucket.com/albums/ii494/Foredoomed/relativepasitioning_zpsa52dd16e.png "relative positioning")

#### 9.5.2 漂浮盒子

漂浮盒子是偏移到一行左边或右边，有趣的特性是其他盒子环绕在它的旁边。

{% hl %}
<p>
  <img style="float:right" src="images/image.gif" width="100" height="100">
  Lorem ipsum dolor sit amet, consectetuer...
</p>
{% endhl %}

的结果会是下面这个样子：

![float](http://i1256.photobucket.com/albums/ii494/Foredoomed/float_zps6781931b.png "float")

#### 9.5.3 绝对和固定盒子

绝对和固定盒子的定义独立于普通流，元素也不参与普通流，它的维度是相对于容器的。固定盒子的容器是viewport。

![fixed positioning](http://i1256.photobucket.com/albums/ii494/Foredoomed/fixedpositioning_zpsf4c26c05.png "fixed positioning")

注意：固定盒子不会移动，即使下拉窗口！

### 9.6 基于层次的表现形式

它是用CSS中的z-index来指定的，它代表了盒子的第三维度，它的位置是沿着Z轴的。盒子被分成很多堆(称为堆积上下文)，在每个堆里最后一个元素首先被绘制，然后是前面的元素，所以前面的元素更靠近用户。为了防止重叠，先绘制的元素将被隐藏。

堆是根据z-index属性来排序的，盒子是和z-index属性一起存放在本地堆中，viewport则有外部堆。

例如：

{% hl %}
<style type="text/css">
      div { 
        position: absolute; 
        left: 2in; 
        top: 2in; 
      }
</style>

<p>   
    <div style="z-index: 3;background-color:red; width: 1in; height: 1in; ">
    </div>
    <div style="z-index: 1;background-color:green;width: 2in; height: 2in;">
    </div>
 </p>
{% endhl %}

结果会是下面这个样子：


![fixed positioning](http://i1256.photobucket.com/albums/ii494/Foredoomed/fixedpositioning2_zpsaab87119.png "fixed positioning")

尽管红色div声明在绿色之前而且会被首先绘制，但是它z-index属性值更大，所以它在根盒子持有的堆中位置更靠前。

**全文完**
