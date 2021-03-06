---
layout: post
title: "字符串搜索算法"
date: 2012-10-20 22:30 
---
## Brute-force search (BFS)

BFS应该是字符串搜索算法中最简单的一个，维基百科上的描述是：

> a trivial but very general problem-solving technique that consists of systematically enumerating all possible candidates for the solution and checking whether each candidate satisfies the problem's statement.

所以BFS算法就是用模式串去和搜索串逐一比较，直到找到模式串为止。

![BFS](http://i1256.photobucket.com/albums/ii494/Foredoomed/bruteforcesearch_zps3f5d214f.png "BFS")

#### BFS的特点：

* 模式串不做预处理
* 从左边开始一个字符一个字符的匹配
* 最差情况下需要比较mn次
* 返回的是第一次匹配的字符串

BSF的优点和缺点都很明显：优点就是简单；缺点速度慢，不稳定。

## Knuth-Morris-Pratt (KMP)

维基百科上的描述是：

> searches for occurrences of a "word" W within a main "text string" S by employing the observation that when a mismatch occurs, the word itself embodies sufficient information to determine where the next match could begin, thus bypassing re-examination of previously matched characters.

BFS算法最大的问题就是当匹配失败时，需要把模式串右移一位重新开始匹配。但是很有可能匹配失败，然后再右移一位匹配。这当中重复了很多不必要的匹配过程，这也是造成BFS算法效率差的原因(当搜索串不是很大时，BFS应该比其他算法更有优势)。

KMP解决了不必要匹配过多的问题，大大提高了算法的效率。显然，匹配的核心问题就是当匹配失败出现时，模式串右移多少位再开始重新匹配。KMP算法是通过对模式串的预处理，建立一张前缀表来实现。

{% hl %}
i    0  1  2  3  4  5  6
W[i] A  B  C  D  A  B  D   
T[i] -1 0  0  0  0  1  2  
{% endhl %}

建立这张表的算法是：从左往右遍历模式串，观察前i-1长子串中，最长前缀子串和后缀子串匹配的长度。如上图所示，匹配串W[i]=ABCDABD的第一个字符是a，约定T[0]=-1；W[1]之前的字串是A，因为只有一个字符，它没有前缀子串和后缀子串，所以T[1]=0；同理T[2]=0，T[3]=0，T[4]=0；当W[5]=ABCDA时，有前缀和后缀字串A，所以T[5]=1；同理T[6]=2。

我们来看下面的例子：

{% hl %}
0	1	2	3	4	5	6	7	8	9
a	b	c	a	b	c	a	b	d		
a	b	c	a	b	d					
        a	b	c	a	b	d
{% endhl %}
          
当i=5时匹配失败，又T[5]=2，所以模式串往右移i-T[5]=5-2=3位继续匹配。

#### KMP算法的特点：

* 从左往右匹配
* 预处理模式串，时间负责度Θ(m)
* 搜索时间负责度Θ(m+n)`
* 最多比较2n-1`次

KMP算法的优点有：简单，速度快，对处理大文件有优势；缺点是随着字符种类增加，匹配失败的几率也随之增加。

## Boyer-Moore (BM)

维基百科上的描述是：

> is an efficient string searching algorithm that is the standard benchmark for practical string search literature. It was developed by Robert S. Boyer and J Strother Moore in 1977. The algorithm preprocesses the string being searched for (the pattern), but not the string being searched in (the text). It is thus well-suited for applications in which the text does not persist across multiple searches. The Boyer-Moore algorithm uses information gathered during the preprocess step to skip sections of the text, resulting in a lower constant factor than many other string algorithms. In general, the algorithm runs faster as the pattern length increases.

简单来说，BM算法是从模式串的右边开始往左边匹配搜索串，如果搜索串中的字符与模式串最右的字符不匹配，并且模式串里不包含这个字符的话，那么模式串可以右移m(模式串的长度)位。

例子：

{% hl %}
0	1	2	3	4	5	6	7	8	9	
a	b	b	a	d	a	b	a	c	b	a
b	a	b	a	c						
                b	a	b	a	c
{% endhl %}
                 
### 0.Bad character 搜索法

{% hl %}
0	1	2	3	4	5	6	7	8	9  
a	b	b	a	b	a	b	a	c	b	a
b	a	b	a	c						
        b	a	b	a	c  
{% endhl %}
    
首先匹配i=4位置上的b和c，显然不相等，然后我们发觉b在模式串中出现在了0和2的位置上，所以我们可以把搜索串i=4位置上的b和模式串i=2位置上的b对齐。

### 1.Good suffix 搜索法	

{% hl %}    
0	1	2	3	4	5	6	7	8	9   
a	b	a	a	b	a	b	a	c	b	a  
c	a	b	a	b						
        c	a	b	a	b  
{% endhl %}

从右开始匹配到i=2时匹配失败，这时后缀ab匹配成功，我们可以把模式串中的下一个ab(如果有的话)与搜索串的ab对齐。但是如果碰到下面这种情况：

{% hl %}
0	1	2	3	4	5	6	7	8	9  
a	a	b	a	b	a	b	a	c	b	a
a	b	b	a	b						
        a	b	b	a	b		
{% endhl %}

我们可以看到后缀bab匹配成功，但是模式串中没有第二个bab，所以我们可以在模式串中寻找bab的字串，就像上面的ab，然后把它与搜索串对齐。

#### BM算法的特点：

* 从右往左匹配
* 预处理模式串，时间负责度Θ(m+σ)
* 搜索时间负责度Θ(m*n)`
* 最多比较3n次
	
BM算法是字符串搜索算法里效率最高的算法，但是缺点是比较复杂(需要考虑的情况很多)，对good suffix的预处理比较难理解和实现。

##参考资料

* [Wikipedia-Brute-force searching algorithm](http://en.wikipedia.org/wiki/Brute-force_search "Wikipedia，Brute-force searching algorithm")  
* [Wikipedia-Knuth–Morris–Pratt algorithm](http://en.wikipedia.org/wiki/Knuth%E2%80%93Morris%E2%80%93Pratt_algorithm "Wikipedia，Knuth–Morris–Pratt algorithm")  
* [Wikipedia-Boyer–Moore string search algorithm](http://en.wikipedia.org/wiki/Boyer%E2%80%93Moore_string_search_algorithm "Wikipedia，Boyer–Moore string search algorithm")  
* [algorithms](http://www.inf.fh-flensburg.de/lang/algorithmen/pattern/ "algorithms")

