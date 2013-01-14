---
layout: post
title: "用Gradle来构建和测试项目"
date: 2013-01-14 19:50
---

## 什么是Gradle

[Gradle](http://www.gradle.org/ "Gradle")是一个Java项目自动化编译，测试和部署工具。我们知道Java平台上有许多类似的工具，比如Ant，Ivy，Maven，Buildr等，前面三个工具是用基于XML的，而Buildr是基于Ruby的。但是与这些工具不同的是，Gradle是基于Groovy的DSL来构建项目的。这样做的好处就是把程序员从大段不友好的XML中解放出来，并且利用Groovy语言的优势使得构建项目变得更加容易，构建文件也更友好和易读。

## Hello Gradle

首先是安装Gradle，如果是MacOS系统并且已经安装了[Homebrew](http://mxcl.github.com/homebrew/ "Homebrew")的话这部将会非常简单，只需要在终端中执行

{% hl %}

$ sudo brew install gradle

{% endhl %}

这样Gradle就安装好了，然后执行 gradle -v 命令，如果出现下面下面的信息就说明安装完成了。

{% hl %}

-----------------------------------------------------------

Gradle 1.3

-----------------------------------------------------------

Gradle build time: Tuesday, November 20, 2012 11:37:38 AM UTC  
Groovy: 1.8.6  
Ant: Apache Ant(TM) version 1.8.4 compiled on May 22 2012  
Ivy: 2.2.0  
JVM: 1.7.0_09 (Oracle Corporation 23.5-b02)  
OS: Mac OS X 10.7.5 x86_64  

{% endhl %}

前面已经说过Gradle使用的是Groovy语言作为DSL来构建项目，现在我们就用Gradle来构建第一个项目。

首先是HelloWorld.java

{% hl %}

package info.liuxuan.gradle.example
public class HelloWorld {
public static void main(String args[]) {  	System.out.println(“hello, world”); }  }

{% endhl %}

然后在项目根目录创建 build.gradle 文件，并且加入下面这行

{% hl %}

apply plugin: 'java'

{% endhl %}

编译和测试Java源代码需要Java插件的支持，Gradle有丰富的插件[资源](http://www.gradle.org/plugins "资源")来帮助你完成各种构建和测试任务。

现在只要在终端中切换到项目根目录并执行

{% hl %}

gradle build

{% endhl %}

这样Gradle就会自动编译src/main/java目录下的源代码，并且执行src/main/test目录下的单元测试，等待片刻我们就可以看到编译成功的信息

{% hl %}

:compileJava UP-TO-DATE  
:processResources UP-TO-DATE  
:classes UP-TO-DATE  
:jar  
:assemble  
:compileTestJava UP-TO-DATE  
:processTestResources UP-TO-DATE  
:testClasses UP-TO-DATE  
:test  
:check  
:build  

BUILD SUCCESSFUL

Total time: 4.418 secs

{% endhl %}

我们还可以看到在项目根目录下生成了一个新的目录build，其中有打好包的jar文件，还有基于HTML的单元测试结果文件，直接双击就能查看，现在我们没有单元测试类，所以里面也什么都没有。

gradle build 命令会执行以下操作

* 下载声明过的依赖包到目录：~/.gradle/cache
* 编译 src/main/java 目录下的源代码并把class文件输出到 build/classes/main 目录
* 尝试执行单元测试，并把结果用XML和HTML文件形式分别输出到 build/test-results/ 目录和 build/reports/tests/ 目录
* 在 build/tmp/jar 目录下创建 MANIFEST.MF 文件
* 把 class 文件和 MANIFEST.MF 文件压缩打包到 build/libs 目录

## 复杂一点的构建

{% hl %}

apply plugin: 'java'  
apply plugin: 'maven'

repositories {  
	mavenCentral()  
}

dependencies {

	compile(  
   		'com.google.guava:guava:13.0.1',  
		'io.netty:netty:3.6.1.Final',  
		'org.slf4j:slf4j-api:1.7.2',  
		'commons-io:commons-io:2.4'  
	)

	runtime(  
		'com.googlecode.sli4j:sli4j-slf4j-logback:2.0',  
		'ch.qos.logback:logback-classic:1.0.9'  
	)

	testCompile(  
		'junit:junit:4.10',  
		'org.mockito:mockito-all:1.9.0',  
		'org.apache.httpcomponents:httpcore:4.2.1',  
		'org.apache.httpcomponents:httpclient:4.2.1',  
		'org.apache.httpcomponents:fluent-hc:4.2.1',  
		'commons-logging:commons-logging:1.1.1',  
	)
	
}

task sourcesJar(type: Jar) {  
     classifier = 'sources'  
     from sourceSets.main.allSource  
}

artifacts {  
     archives sourcesJar  
}

{% endhl %}

在这个构建文件中加入了项目依赖的配置，在Gradle中使用Maven仓库来管理依赖的jar包非常方便，只需要引入Maven插件，然后所需jar包只要以 **group:name:version** 的形式配置就可以了，比pom的配置精简和清晰了很多。

其中还定义了一个叫sourcesJar的task，并且这个task类型是Jar，Gradle内建了许多类型的task，具体可以参考文档。Gradle的task概念和Ant以及Maven的task在概念上差不多，只不过Gradle的task更加强大。我们创建了类型是Jar的task，顾名思义就是打jar包的task，所以sourcesJar的作用就是把源文件打成jar包。

Gradle还可以重用Ant的构建文件或者Maven的pom文件，所以如果你以前用Ant或者Maven的话，转到Gradle是一件非常容易的事。

## 总结

现在回头来看build.gradle文件，是不是很清楚，很好读？在我看来，这就是Gradle最大的优势所在。

## 参考资料

* [Gradle document](http://www.gradle.org/documentation "Gradle document")