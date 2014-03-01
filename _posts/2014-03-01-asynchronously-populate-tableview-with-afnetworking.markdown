---
layout: post
title: 用AFNetworking为TableView异步加载数据
date: 2014-03-01 10:58
---
为了让APP有更好的用户体验，所以是不能阻塞主线程的，而RSS的获取和解析都需要一定的时间，所以需要异步地来处理这些工作。

首先要准备一下UI部分。在stroyboard中，删除项目自动生成的ViewController，重新拖一个TableViewController上去，然后分别创建一个TableViewController类，继承UITableViewController，和TableCell类，继承UITableViewCell。

在TableViewController.h中定义一个Feed属性：

{% hl %}

#import <UIKit/UIKit.h>
#import "Feed.h"

@interface TableViewController : UITableViewController
@property(nonatomic, retain) Feed *feed;
@end

{% endhl %}

在TableCell.h中定义一个Label属性：

{% hl %}

#import <UIKit/UIKit.h>

@interface TableCell : UITableViewCell
@property(nonatomic, strong) IBOutlet UILabel *entryLabel;

@end

{% endhl %}

把解析RSS的代码放到TableViewController.m中：

{% hl %}

- (void)loadFeed {
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
    }
failure:
  ^(AFHTTPRequestOperation * operation, NSError * error) {
    NSLog(@"error: , %@", error);
  }];
}

{% endhl %}

重写TableView的数据源方法：

{% hl %}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {

  // Return the number of rows in the section.
  return self.feed.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"TableCell";
  TableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                    forIndexPath:indexPath];

  // Configure the cell...

  int row = [indexPath row];
  Entry *entry = [self.feed.entries objectAtIndex:row];
  cell.entryLabel.text = entry.title;

  return cell;
}

{% endhl %}

完成后的TableViewController.m就会是这样的：

{% hl %}

#import "TableViewController.h"
#import "AFNetworking.h"
#import "Feed.h"
#import "FeedParser.h"
#import "Entry.h"
#import "TableCell.h"

@interface TableViewController ()

@end

static NSString *const URL = @"http://v2ex.com/index.xml";

@implementation TableViewController

- (void)loadFeed {
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
    }
failure:
  ^(AFHTTPRequestOperation * operation, NSError * error) {
    NSLog(@"error: , %@", error);
  }];
}

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  // Uncomment the following line to display an Edit button in the navigation
  // bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;

  [self loadFeed];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {

  // Return the number of rows in the section.
  return self.feed.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"TableCell";
  TableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                    forIndexPath:indexPath];

  // Configure the cell...

  int row = [indexPath row];
  Entry *entry = [self.feed.entries objectAtIndex:row];
  cell.entryLabel.text = entry.title;

  return cell;
}

@end

{% endhl %}

最后运行看一下结果：

![TableView Example](http://i1256.photobucket.com/albums/ii494/Foredoomed/ScreenShot2014-03-01at123008PM_zps80704577.png)