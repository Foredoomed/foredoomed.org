---
layout: post
title: 初试AFNetworking
date: 2014-02-23 20:24
---
RSS还是要通过发送网络请求来获取的，Objective-C中的NSURLConnection类可以完成对网络的请求处理。但是还有一个更方便好用的开源网络库：[AFNetworking](http://afnetworking.com/)。

首先创建一个RSSService类，然后再定义一个getRSS方法：

{% hl %}

//
//  RSSService.h
//  vot
//
//  Created by Foredoomed on 2/23/14.
//  Copyright (c) 2014 Foredoomed. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Feed;

@interface RSSService : NSObject

- (void *)getRSS;

@end

{% endhl %}

在实现类中用AFHTTPRequestOperationManager这个类发送GET请求：

{% hl %}

//
//  RSSService.m
//  vot
//
//  Created by Foredoomed on 2/23/14.
//  Copyright (c) 2014 Foredoomed. All rights reserved.
//

#import "NetWorkService.h"
#import "AFNetworking.h"
#import "Feed.h"
#import "FeedParser.h"
#import "Entry.h"

static NSString *const URL = @"http://v2ex.com/index.xml";

@implementation RSSService

- (void)getRSS {
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];

  AFHTTPResponseSerializer *responseSerializer =
      [AFHTTPResponseSerializer serializer];

  responseSerializer.acceptableContentTypes =
      [NSSet setWithObjects:@"application/atom+xml", nil];
  manager.responseSerializer = responseSerializer;

  [manager GET:URL parameters:nil
  success:^(AFHTTPRequestOperation *operation, id responseObject){
      NSData *data = (NSData *)responseObject;
      Feed *feed = [FeedParser parse:data];

      if (feed != nil) {
        for (Entry *entry in feed.entries) {
          NSLog(@"%@", entry.title);
        }
      }
    }
  failure:^(AFHTTPRequestOperation * operation, NSError * error) {
    NSLog(@"error: , %@", error);
  }];
}

@end

{% endhl %}

这里，AFHTTPRequestOperationManager发送的是异步请求，所以block中的代码执行会有时间差，这就好比Javascript中回调函数的存在。从试用的结果来看，AFNetworking对网络操作非常方便，以后再试试别的功能。