---
layout: post
title: "用火焰图分析Java程序性能"
date: 2018-02-08 19:14
---
火焰图是一个非常好的性能分析工具，在火焰图上可以很直观的看到哪个方法执行的时间长，而这个方法就是可以优化的点。在生成火焰图之前需要收集JVM的运行时数据，我用的是一个叫[async-profiler](https://github.com/jvm-profiling-tools/async-profiler)的工具。首先下载解压后进入目录执行`make`命令，执行完会生成build文件夹。然后执行`chmod 777 *`命令，让等会需要执行的文件能够被执行。

好了，现在开始收集数据。首先执行`jcmd`命令找到你要监控的Java程序的进程ID，打个比方`1024`。然后执行命令：
{% hl %}
./profiler.sh -d 300 -o collapsed -f /tmp/collapsed.txt 1234
{% endhl %}

这个命令的含义是：收集进程ID为1234的程序执行数据300秒，保存到格式为collapsed，文件名为collapsed.txt的文件。等5分钟后，collapsed.txt文件就生成了，有了这个数据文件就可以生成火焰图了。首先下载火焰图工具[FlameGraph](https://github.com/brendangregg/FlameGraph)，解压后进入目录并执行命令：

{% hl %}
/flamegraph.pl --colors=java /tmp/collapsed.txt > collapsed.svg
{% endhl %}

等执行完后用浏览器打开collapsed.svg就可以看到火焰图了：
![火焰图](http://i1256.photobucket.com/albums/ii494/Foredoomed/flamegraph_zpsjgc5j96j.png)

从上图可以看到iBatis的executeSelectKey方法占用了相当长的CPU时间，所以要考虑去掉insert语句里的selectKey标签。