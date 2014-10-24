---
layout: post
title: JavaScirpt的立即调用函数表达式
date: 2014-10-24 21:31
---

说起JavaScript的立即调用的函数表达式(IIFE,Immediately-Invoked Function Expression),随便找一个JS框架或者类库就能看到它的存在。不过，最近在看[Underscore.js](underscorejs.org)源代码的时候又发现了一种新的写法，
这马上激起了我的好奇心，所以这次就来好好地研究一下。
 
## 0. IIFE的写法
 
IIFE的作用就是限制函数和变量的作用域，常见写法有两种：
 
{% hl %}
// Crockford's preference
(function() {
  console.log('Hello World.');
}());
 
(function() {
  console.log('Hello World.');
})();
{% endhl %}
 
为什么像这样写法就是IIFE了呢？这是因为JS解释器规定了小括号内的内容必定是表达式，而不可能是函数声明或其他。当然IIFE还可以写成下面这种形式：
 
{% hl %}
!function(){ console.log('Hello World.'); }();
 
~function(){ console.log('Hello World.'); }();
 
-function(){ console.log('Hello World.'); }();
 
+function(){ console.log('Hello World.'); }();
{% endhl %}
 
上面这样写法也是IIFE的原因就是：!,~,-,+操作符后只能跟表达式，所以JS解释器就会把这些符号后的JS语句作为表示式处理。
 
不过在Underscore.js的源代码中，它的IIFE都不是上面的这些写法，而是写成这样的：
 
{% hl %}
(function() {
 
}.call(this));
{% endhl %}
 
那么问题来了，Underscore.js为什么要这么写？要弄清楚这个问题，首先要搞清楚JS的函数调用。
 
## 1. JavaScirpt的函数调用
 
在[ECMAScript 5.1](http://es5.github.io/#x15.3.4.4)规范中，关于函数调用部分是这样描述的：
 
>15.3.4.4 Function.prototype.call (thisArg [ , arg1 [ , arg2, … ] ] )
When the call method is called on an object func with argument thisArg and optional arguments arg1, arg2 etc, the following steps are taken:
 
>If IsCallable(func) is false, then throw a TypeError exception.
Let argList be an empty List.
If this method was called with more than one argument then in left to right order starting with arg1 append each argument as the last element of argList
Return the result of calling the [[Call]] internal method of func, providing thisArg as the this value and argList as the list of arguments.
The length property of the call method is 1.
 
>NOTE The thisArg value is passed without modification as the this value. This is a change from Edition 3, where a undefined or null thisArg is replaced with the global object and ToObject is applied to all other values and that result is passed as the this value.
 
也就是说当调用函数类型的原型中的call函数时，第一个参数是thisValue，从第二个参数开始才是真正的函数的参数。例如：
 
{% hl %}
function test(arg) {
  console.log(this + " is not " + arg);
}
 
test.call("foo", "bar") // foo is not bar
{% endhl %}
 
可以看到，在test函数被调用的时候，this的值被设置成了字符串foo，这也就验证了ECMAScript规范中的说明。讲了这么多有同学可能会有疑问，比如：我们自己调用函数肯定不会像这样调用原型里的call函数，而是直接用函数名加小括号的形式来完成函数的调用，那么call函数跟我们有什么关系呢。
那接下来就来说明这两种调用方式的联系。
 
## 2. 一般函数调用与call函数的联系
 
我们先来定义一个函数，在这个函数里把this的值打印出来：
 
{% hl %}
function test() {
  console.log(this);
}
 
test(); // Window
{% endhl %}
 
有趣的事情发生了，this没有作为参数传入，但是默认设置成了Window对象。联系ECMAScript中关于函数调用的规范，我们可以得到这样的推测：
 
在JS解释器执行函数的时候，会把形如function([args...])形式的函数调用转换成形如function.call(Window, [args...])的函数调用。
 
通过这样的转换，Window对象自然而然成为了函数默认的this的值。我们已经越来越接近真相了，下面来看一下成员函数中this的值是怎么样的。
 
## 3. 成员函数中的this
 
同样，首先定义一个类，然后在其中再定义一个成员函数：
 
{% hl %}
var foo = {
  bar: function(arg) {
    console.log(arg);
    console.log(this);
  }
}
{% endhl %}
 
执行一下这个bar函数试试：
 
{% hl %}
foo.bar("hello world"); // hello world Object
{% endhl %}
 
可以看到打印出来的this的值是一个Object，而这个Object对象的类型就是foo。那么跟一般函数的转换调用一样，成员函数在被调用的过程中也有一个转换的过程，这个过程就是：
 
foo.bar("hello world") => foo.bar.call(foo, "hello world")
 
到这里为止，关于JS函数调用的基础知识已经完备，现在回到本文的开头，来研究一下Underscore.js的IIFE写法。
 
## 4. Underscore.js的IIFE写法
 
Underscore.js的IIFE是这样写的：
 
{% hl %}
(function(){
 
}.call(this));
{% endhl %}
 
这样就显示地指定call函数第一个参数为this，那么这个this的值是什么呢？如果这段代码是在浏览器里执行的话，this就是Window对象。但是如果是在服务器端执行的话，那么这个this就是上下文对象了。直接看代码：
 
{% hl %}
function Foo() {
  this.foo = true;
 
  (function () {
      console.log(this); // Window
  })();
 
  (function () {
      console.log(this.foo); // undefined
  }());
 
  (function () {
      console.log(this.foo); // true
  }).call(this);
}
 
var foo = new Foo;
{% endhl %}

从上面的代码可以看出，这样的写法保证了在IIFE内部引用到的this值是这个IIFE在上下文当中的对象。