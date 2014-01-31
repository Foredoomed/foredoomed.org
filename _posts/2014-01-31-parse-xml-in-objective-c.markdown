---
layout: post
title: 在Objective-C中解析XML
date: 2014-01-31 17:20
---
自从最近买了iPhone以后就开始学习Objective-C，想做一个RSS阅读器作为我的第一个APP。要做RSS阅读器的第一步就是解析XML，如果是Java的话，使用JAXB一条语句就可以完成XML到对象的解析，而Objective-C虽然没有JAXB，但好在也不是很麻烦。

我就拿V2EX的RSS文件作为解析的例子，V2EX的RSS格式是这样的：

{% hl %}

<entry>
  <title>[问与答] 关于google开发者注册的问题</title>
  <link rel="alternate" type="text/html" href="http://www.v2ex.com/t/98748#reply0" />
  <id>tag:www.v2ex.com,2014-01-31:/t/98748</id>
  <published>2014-01-31T06:32:02Z</published>
  <updated>2014-01-31T06:29:02Z</updated>
  <author>
    <name>ufo22940268</name>
    <uri>http://www.v2ex.com/member/ufo22940268</uri>
  </author>
  <content type="html" xml:base="http://www.v2ex.com/" xml:lang="en"><![CDATA[
  最近想在play store上发布些东西，然后就去买了一个google开发者。可是一直出问题。<br /><br />第一次买了之后，回复我账号需要验证，然后账号被suspend，然后我就按照步骤上传了各种数据。结果今天解锁了。于是兴匆匆又去买了一次，结果wallet账号又被suspend，和第一次一样的问题。我的天<br /><br />各位有碰到同样的问题吗，怎么解决的？
  ]]></content>
</entry>

{% endhl %}

从中我们可以看到一个entry有title，link，published，author，content这样5个元素，所以我们就先来定义一个Entry类。

{% hl %}

//
//  Entry.h
//  vot
//
//  Created by Foredoomed on 1/31/14.
//  Copyright (c) 2014 Foredoomed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Entry : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *link;
@property(nonatomic, copy) NSDate *publishedDate;
@property(nonatomic, copy) NSString *author;
@property(nonatomic, copy) NSString *content;

- (id)initWithTitle:(NSString *)title
               link:(NSString *)link
      publishedDate:(NSDate *)publishedDate
             author:(NSString *)author
            context:(NSString *)content;

@end


//
//  Entry.m
//  vot
//
//  Created by Foredoomed on 1/31/14.
//  Copyright (c) 2014 Foredoomed. All rights reserved.
//

#import "Entry.h"

@implementation Entry

- (id)initWithTitle:(NSString *)title
               link:(NSString *)link
      publishedDate:(NSDate *)publishedDate
             author:(NSString *)author
            context:(NSString *)content {

  self = [super init];
  if (self) {
    self.title = title;
    self.link = link;
    self.publishedDate = publishedDate;
    self.author = author;
    self.content = content;
  }

  return self;
}

@end

{% endhl %}

上面Entry类还是非常简洁明了的，只定义了属性和初始化函数。因为RSS中包含有多个Entry，所以还需要定义一个Feed类。

{% hl %}

//
//  Feed.h
//  vot
//
//  Created by Foredoomed on 1/31/14.
//  Copyright (c) 2014 Foredoomed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feed : NSObject

@property(nonatomic, retain) NSMutableArray *entries;

@end


//
//  Feed.m
//  vot
//
//  Created by Foredoomed on 1/31/14.
//  Copyright (c) 2014 Foredoomed. All rights reserved.
//

#import "Feed.h"

@implementation Feed

- (id)init {

  self = [super init];
  if (self) {
    self.entries = [[NSMutableArray alloc] init];
  }
  return self;
}

@end


{% endhl %}

接下来就可以开始解析XML了。Objective-C中已经包含有原生的XML解析类NSXMLParser，但是如果直接用的话还是稍微有点复杂，所以我就用了[GDataXML](https://code.google.com/p/gdata-objectivec-client/)，这是Google的XML解析类库，简单又好用。

首先定义一个解析类FeedParser来负责所有XML解析的逻辑：

{% hl %}

//
//  FeedParser.h
//  vot
//
//  Created by Foredoomed on 1/31/14.
//  Copyright (c) 2014 Foredoomed. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Feed;

@interface FeedParser : NSObject

+ (Feed *)parse;

@end


//
//  FeedParser.m
//  vot
//
//  Created by Foredoomed on 1/31/14.
//  Copyright (c) 2014 Foredoomed. All rights reserved.
//

#import "FeedParser.h"
#import "Feed.h"
#import "GDataXMLNode.h"
#import "Entry.h"

@implementation FeedParser


+ (Feed *)parse:(NSString *)xml {

  NSString *file = [[NSBundle mainBundle] pathForResource:@"v2ex" ofType:@"xml"];
  NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:file];
  NSError *error;
  GDataXMLDocument *document =
      [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];

  if (document == Nil) {
    return nil;
  }

  Feed *feed = [[Feed alloc] init];

  NSArray *entries = [document.rootElement elementsForName:@"entry"];
  for (GDataXMLElement *element in entries) {
    NSString *title = nil;
    NSString *link = nil;
    NSDate *publishedDate = nil;
    NSString *author = nil;
    NSString *content = nil;

    NSArray *titles = [element elementsForName:@"title"];
    if (titles.count > 0) {
      GDataXMLElement *xe = (GDataXMLElement *)[titles objectAtIndex:0];
      title = xe.stringValue;
    }

    NSArray *links = [element elementsForName:@"link"];
    if (links.count > 0) {
      GDataXMLElement *xe = (GDataXMLElement *)[links objectAtIndex:0];
      link = xe.stringValue;
    }

    NSArray *publishedDates = [element elementsForName:@"published"];
    if (publishedDates.count > 0) {
      GDataXMLElement *xe = (GDataXMLElement *)[publishedDates objectAtIndex:0];
      NSString *published = xe.stringValue;

      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
      publishedDate = [formatter dateFromString:published];
    }

    NSArray *authors = [element elementsForName:@"author"];
    if (authors.count > 0) {
      GDataXMLElement *xe = (GDataXMLElement *)[authors objectAtIndex:0];
      author = xe.stringValue;
    }

    NSArray *contents = [element elementsForName:@"content"];
    if (contents.count > 0) {
      GDataXMLElement *xe = (GDataXMLElement *)[contents objectAtIndex:0];
      content = xe.stringValue;
    }

    Entry *entry = [[Entry alloc] initWithTitle:title
                                           link:link
                                  publishedDate:publishedDate
                                         author:author
                                        context:content];

    [feed.entries addObject:entry];
  }

  [document release];
  [file release];

  return feed;
}

@end


{% endhl %}

解析的代码也是非常直观，只要循环获取每个元素然后再调用Feed类的初始化函数就可以了。最后检验一下解析是否成功：

{% hl %}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.

  self.feed = [FeedParser parse];
  if (self.feed != nil) {
    for (Entry *entry in self.feed.entries) {
      NSLog(@"%@", entry.title);
    }
  }

  return YES;
}

{% endhl %}

运行程序就会输出：

{% hl %}

2014-01-31 17:17:07.825 vot[21867:70b] [音乐] 自家电台。。
2014-01-31 17:17:07.827 vot[21867:70b] [问与答] 新的一年开始了，准备每周跑步的量再大一点。一直不赞成跑得越多就越好的想法，但不知道怎么样的量对身体是好的。大家一般采用什么来衡量？
2014-01-31 17:17:07.827 vot[21867:70b] [Mac OS X] Gmail Notifr 上架 Mac App Store，新春 3 天免费
2014-01-31 17:17:07.828 vot[21867:70b] [问与答] 关于google开发者注册的问题
2014-01-31 17:17:07.828 vot[21867:70b] [二手交易] 送一个中信的9分享兑
2014-01-31 17:17:07.829 vot[21867:70b] [微信] 建个微信群发红包玩，希望抛砖引玉引出大土豪大大钱
2014-01-31 17:17:07.829 vot[21867:70b] [二手交易] 出一个全新移动电源 京东138块 100块出
2014-01-31 17:17:07.830 vot[21867:70b] [Windows] 今年关注wintel平板
2014-01-31 17:17:07.830 vot[21867:70b] [Mac OS X] CocoaPods经常没法使用怎么办？
2014-01-31 17:17:07.830 vot[21867:70b] [Mac OS X] 请教如何添加文件的打开方式？
2014-01-31 17:17:07.831 vot[21867:70b] [问与答] 关于小额分期付款
2014-01-31 17:17:07.832 vot[21867:70b] [问与答] 请问如何设置github时间为本地时间(GMT+8)?
2014-01-31 17:17:07.832 vot[21867:70b] [iPhone] things的同步好像失效了，改hosts和apn都有问题。。

{% endhl %}