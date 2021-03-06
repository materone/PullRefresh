//
//  ViewController.m
//  PullRefresh
//
//  Created by tony on 14-7-29.
//  Copyright (c) 2014年 tony. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
    @property (nonatomic) int count;
    @property (nonatomic,retain) NSMutableArray *countArr;
@end

@implementation ViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.count = 0;
    self.countArr = [[NSMutableArray alloc]initWithCapacity:16];
    UIRefreshControl *refresh =[[UIRefreshControl alloc]init];
    refresh.tintColor = [UIColor lightGrayColor];
    refresh.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull to refresh"];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

#pragma mark - Table view pull refresh
-(void)refreshView:(UIRefreshControl *)refresh{
    if (refresh.refreshing) {
        refresh.attributedTitle = [[NSAttributedString alloc]initWithString:@"Refreshing data..."];
        [self performSelector:@selector(handleData) withObject:nil afterDelay:0];
    }
    [self test];
}

-(void)test{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://localhost:3000/index.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *url = nil;
        NSString *fileName = nil;
        NSString *size = nil;
        NSString *idStr = nil;
        NSString *body = nil;
        NSString *title = nil;
        NSLog(@"JSON: %@", responseObject);
        if ([responseObject isKindOfClass:[NSArray class]]) {
            for (id comobj in responseObject) {
                //NSLog(@"==>%@",comobj);
                if ([comobj isKindOfClass:[NSDictionary class]]) {
                    idStr = [comobj objectForKey:@"_id"];
                    body = [comobj objectForKey:@"body"];
                    title = [comobj objectForKey:@"title"];
                    id image = [comobj objectForKey:@"image"];
                    if (![image isKindOfClass:[NSNull class]]) {
                        url = [NSString stringWithFormat:@"http://127.0.0.1:3000%@",[image objectForKey:@"url"]];
                        fileName = [image objectForKey:@"filename"];
                        size = [image objectForKey:@"size"];
                    }else{
                        url = nil;
                        fileName = nil;
                        size = nil;
                    }
                    
                    NSLog(@"%@:%@:%@:%@:%@:%@",idStr,title,body,url,fileName,size);
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)handleData{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM d, h:mm:ss a"];
    NSString *lastUpdate = [NSString stringWithFormat:@"Last Update On %@",[formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[[NSAttributedString alloc]init]initWithString:lastUpdate];
    int j = arc4random()%1000;
    for (int i = 0; i<j; i++) {
        self.count++;
        [self.countArr addObject:[NSString stringWithFormat:@"%d. %@, Refresh In Tony",self.count,[formatter stringFromDate:[NSDate date]]]];
    }
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.countArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.countArr objectAtIndex:(self.countArr.count - indexPath.row - 1)];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

#pragma mark -
/**
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.refreshControl beginRefreshing];
}
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
