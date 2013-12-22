---
layout: post
title: "Effective Javascript的笔记"
date: 2013-12-19 19:59
---
今天通读了一遍《Effective Javascript》这本书，感觉写得非常好。虽然整本书只有200多页，但是涉及到了编写高质量Javascript程序需要注意的方方面面，读完后有一种豁然开朗的感觉，所以做一下笔记备忘。

## 0.了解你使用的Javascript遵循的标准

目前Javascript的官方标准是[ECMAScript](http://www.ecmascript.org/)，最新的版本是[ECMAScript5](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf)。但是有的浏览器的Javascript引擎并不是严格遵循ECMAScript规范的，例如ECMAScript规范中没有定义过const关键字，但是有的JS引擎会把声明为const的变量作为常量处理，类似C语言；还有的浏览器就会把const关键字当作var关键字来处理。

{% hl %}

const PI = 3.1415926;
PI = "modified!";
PI; // 3.1415926

const PI = 3.1415926;
PI = "modified!";
PI; // "modified!"

{% endhl %}

ECMAScript的每个版本都在演进，在第五版中新增了『严格模式（strict mode）』，用来提供更彻底的错误检查。更具体的关于严格模式的内容可以看阮一峰的这篇[博客](http://www.ruanyifeng.com/blog/2013/01/javascript_strict_mode.html)。

## 1.理解Javascript中的Number类型

在Javascript中，所有的数字都是64位双精度浮点型的Number类型，整形只有它的一个子集。需要注意的是对两个数做逻辑操作的时候，这两个数会先被转换成32位的整形数，然后再对他们做逻辑操作。当然，Javascript也有小数的精度问题。

{% hl %}

0.1 + 0.2; // 0.30000000000000004

{% endhl %}

## 2.当心隐式类型转换

如果运行`3 + true`会得到什么结果？一般都会报错，因为加号两边是不同的数据类型。但是令人惊奇的是Javascript会执行这段代码并且得到4的结果。Javascript到底做了什么？答案是：隐式类型转换。

在Javascript中，像「-，*，/，%」运算符都会把两边的值转换成Number类型再做运算。「+」运算符比较特别，它会根据两边的类型而转型。


{% hl %}

2 + 3； // 5

"hello" + " world"; // "hello world"

"2" + 3; // "23"

2 + "3"; // "23"

1 + 2 + "3"; // "33"

1 + "2" + 3; // "123"

{% endhl %}

前面说过，逻辑操作的时候是要将两边的值转换成整形数值的，利用这个特性就可以方便的将用户输入的String类型转换成Number类型。

{% hl %}

"1" | "2"; // 3

{% endhl %}

需要注意的是，隐式类型转换会隐藏错误。null会被转换成0，undefined会被转换成NaN。NaN是Not a Number的缩写，并且`NaN != NaN`。

## 3.优先选择基本数据类型

Javascript有五种基本数据类型：boolean，number，string，null，undefined。优先选用这些基本数据类型的原因是：他们的包装类无法互相比较，因为他们是不同的对象。

{% hl %}

var s1 = new String("hello");
var s2 = new String("hello");

s1 == s2; // false
s1 === s2; // false

{% endhl %}

需要注意的是：string类型可以直接调用包装类String类型的方法，但是如果是get或set方法的话，就会隐式地创建String类型。

{% hl %}

"hello".someProperty = 17;
"hello".someProperty; // undefined

{% endhl %}

## 4.避免使用『==』来比较不同类型的值

『==』和『===』的区别是前者当两边数值不同类型是会先做隐式类型转换，然后再比较值是否相等，这就会隐藏许多问题，而后者则是严格比较类型和值是否相等。所以要避免使用『==』，而用『===』来比较两个值。

## 5.省略行尾分号的局限

Javascript代码是可以省略结束符分号的，这是因为ECMAScript规范规定：JS引擎会自动在必要的地方添加分号。但是省略分号和隐式类型转换一样会带来很多问题，所以自动插入分号的规则就变得非常重要了。

#### 规则1：分号只会插入到行尾，代码块结尾或者程序结尾。
#### 规则2：如果后一个符号不能被解析的话，会在其之前插入分号。
注意：必须保证『(,[,+,-,/』这几个符号之前有分号。
#### 规则3：分号不会自动插入到for循环的头部。

## 6.把字符串看作是16位的代码单元

## 7.尽量不要使用全局对象

## 8.始终声明局部变量

## 9.不要使用with

如果要调用一个对象中的许多方法的话，使用with会很方便，省去了重复引用对象的麻烦。但是遗憾的是，with代码块中的变量查找范围是从里到外的方式。也就是说如果变量名和对象内的属性名相同的话，程序就会出现问题。

{% hl %}

function f(x, y){
	with(Math){
		return min(round(x), sqrt(y));
	}
}

Math.x = 0;
Math.y = 0;

f(2,3); // 0

{% endhl %}

## 10.适应闭包

* 方法可以引用定义在其之外的变量。
* 闭包可以在创建它的方法之外存活。
* 闭包在内部保存了外部变量的引用，并且可以读写这些变量。

## 11.理解变量提升

* 在代码块中声明的变量会被隐式地提升到包含这个代码块的方法的开始处。
* 重复定义一个变量会被当作同一个变量处理。

## 12.使用立即调用方法来创建局部范围

## 13.当心非匿名函数的作用域

## 14.当心代码块中的函数作用域

## 15.避免使用eval创建局部变量

## 16.使用非直接eval代替直接eval

## 17.理解函数，方法和构造函数调用的区别

## 18.尽量多使用高阶函数

## 19.使用call调用自定对象的方法

## 20.使用apply让函数的参数可变

## 21.使用arguments创建可变参数的函数

## 22.永远不要修改arguments对象

## 23.把arguments保存到变量里

## 24.使用bind指定函数的作用对象

## 25.使用bind简化函数

## 26.用闭包而不是字符串封装代码

## 27.避免依靠函数的toString方法

## 28.避免非标准的栈检查属性

这里的栈指的是函数的调用栈，其中存放的是函数的参数等运行时数据。应该避免使用非标准的arguments.caller，arguments.callee和函数的caller属性。

## 29.理解prototype，getPrototypeOf和\_\_proto\_\_的区别

* C.prototype是用来建立通过new C()创建的对象的原型。
* Object.getPrototypeOf(obj)是ES5的标准方法，用来获取对象的原型。
* obj.\_\_proto\_\_是获取对象原型的非标准方法。

## 30.使用Object.getPrototypeOf代替\_\_proto\_\_

## 31.永远不要修改\_\_proto\_\_

## 32.让构造函数对new不可知

{% hl %}

function User(name, password){
	this.name = name;
	this.password = password;
}

{% endhl %}

如果调用User构造函数的时候忘了new关键字的话，name和password都将成为全局变量。

{% hl %}

var u = User("foo", "bar");
u; // undefined
this.name; // foo
this.password; // bar

{% endhl %}

如果把User函数改为严格模式的话，u就会默认为undefined。所以，为了防止出现这种错误情况，需要对User函数做些修改，当没有new关键字的时候也会返回User对象。

{% hl %}

function User(name, password){
	var self = this instance of User ? this : Object.create(User.prototype);
	self.name = name;
	self.password = password;
	return self;
}

{% endhl %}

需要注意的是，Object.create是ES5独有的方法。在不支持Object.create的环境下，需要手动模拟一下。

{% hl %}

if(typeof Object.create === "undefined"){
	Object.create = function(prototype){
		function C(){}
		C.prototype = prototype;
		return new C();
	}
}

{% endhl %}

## 33.把方法保存在prototype中

## 34.使用闭包保存私有数据

把User函数修改一下：

{% hl %}

function User(name, password){
	this.toString = function(){
		return "[User " + name + "]"
	};
	this.checkPassword = function(password){
		return password === password;
	}
}

{% endhl %}

这样一来，name和password就不会作为User的实例变量存在，因此从函数外部就无法直接读取name和password了。

## 35.把实例数据只保存在对象的实例中

## 36.熟悉this的隐式绑定

* this的范围始终由最近的包含它的函数决定。
* 用一个局部变量来保存this，这样就可以让内部的函数访问到。

## 37.在子类中调用父类的构造函数

## 38.永远不要重用父类的属性名

## 39.不要继承标准库中的类

## 40.把原型当作具体的实现来对待

## 41.不要随便往原型中添加东西

## 42.从Object的实例创建轻量级的字典集合

## 43.使用null防止原型污染

## 44.使用hasOwnProperty防止原型污染

## 45.当需要用到有序集合的时候，用数组代替字典类型

## 46.永远不要往Object.prototype中添加可迭代的属性

因为for...in也会查找原型中的可迭代属性。

## 47.避免在迭代的时候修改对象

## 48.循环数组的时候，使用for而不是for...in

{% hl %}

var scores = [98,74,85,77,93,100,98];
var total = 0;
for(var score in scores){
	total += score;
}

{% endhl %}

上面这段代码将会输出字符串"00123456"而不是数值88。原因就是for...in循环只会迭代key，而数组的key就是数组下标，并且它是字符串类型的。

## 49.使用迭代方法代替循环语句

迭代方法有：forEach，some，every。

## 50.在类数组对象上重用数组方法

## 51.使用数组语义代替Array构造函数来声明数组

## 52.保持约定的一致性

## 53.把undefined当作"No Value"处理

## 54.把选择性参数封装成对象再作为函数的参数

## 55.避免不必要的状态

## 56.使用结构类型让接口更灵活

## 57.区分数组和类数组类型

## 58.避免过度的隐式类型转换

## 59.支持方法链式调用

## 60.不要租塞I/O上的事件队列

建议使用回调函数。

## 61.使用嵌套回调函数来保证异步顺序的正确性

## 62.当心被丢掉的错误

## 63.使用递归来处理异步的循环

## 64.不要租塞计算的事件队列

## 65.使用计数器来执行并行操作

## 66.永远不要同步地调用异步的回调函数

## 67.使用Promise简化异步逻辑



