---
layout: post
title: 下拉刷新TableView
date: 2014-03-04 23:09
---
下拉刷新自从被Tweetie创始人洛伦•布里切特(Loren Brichter)发明后，到现在可以说已经成为了TableView的标配功能。而我的RSS阅读器自然也不能例外，所以今天给它加上下拉刷新的功能。

首先选中TableViewController，然后打开Attribute Inspector面板，把Refreshing设置为Enabled，就像下面这样：

![Enable Refreshing](http://i1256.photobucket.com/albums/ii494/Foredoomed/ScreenShot2014-03-04at111543PM_zps7f02e348.png)

然后修改用来刷新TableView的loadFeed方法：

{% hl %}

- (IBAction)loadFeed {
  [self.refreshControl beginRefreshing];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];

  AFHTTPResponseSerializer *responseSerializer =
      [AFHTTPResponseSerializer serializer];

  responseSerializer.acceptableContentTypes =
      [NSSet setWithObjects:@"application/atom+xml", nil];
  manager.responseSerializer = responseSerializer;

    [manager GET:URL parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject){
      NSData *response = (NSData *)responseObject;
      Feed *feed = [FeedParser parse:response];
      self.feed = feed;

      [self.tableView reloadData];
      [self.refreshControl endRefreshing];
    }
failure:
  ^(AFHTTPRequestOperation * operation, NSError * error) {
    NSLog(@"error: , %@", error);
  }];
}

{% endhl %}

与之前相比，在进入loadFeed方法之后就调用`[self.refreshControl beginRefreshing]`来显示转动的图片，然后在更新完成后再调用`[self.refreshControl endRefreshing]`来隐藏图片。还有就是把方法的返回类型由void变成了IBAction，这样做的目的是为了能够让Refresh Control和loadFeed方法直接关联。所以最后一步只需要在Document Outline中按住Ctrl键，拖动Refresh Control到loadFeed方法上就可以了。

运行程序看一下效果如何：

![Pull to refresh](http://i1256.photobucket.com/albums/ii494/Foredoomed/ScreenShot2014-03-04at113613PM_zpsde51fa12.png)