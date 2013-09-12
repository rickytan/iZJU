//
//  LectureViewController.m
//  iZJU
//
//  Created by 爱机 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Lecture.h"
#import "SVProgressHUD.h"
#import "LectureTableCell.h"
#import "LectureDetailViewController.h"
#import "LectureMyFavViewController.h"

@interface Lecture ()
//- (IBAction)onLongPress:(id)sender;
@property (nonatomic, strong) NSArray *activityItems;
@end

@implementation Lecture
@synthesize tableView = _tableView;
@synthesize activityItems = _activityItems;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"校园信息";
        
        /*
        UIBarButtonItem *myfav = [[UIBarButtonItem alloc] initWithTitle:@"我的收藏"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(onMyFav:)];
        self.navigationItem.rightBarButtonItem = myfav;
         */
    }
    return self;
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass(self.class)
                          bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commonbg.jpg"]];
    [self.tableView setBackgroundView:bg];
    
    
    
    _request = [ZJUActivityRequest dataRequest];
    
    [[ZJUDataServer sharedServer] executeRequest:_request
                                        delegate:self];
    [SVProgressHUD showWithStatus:@"加载中..."];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[ZJUDataServer sharedServer] cancelRequest:_request];
    [SVProgressHUD dismiss];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView Delegate & Datasource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.activityItems.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LectureTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LectureCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LectureTableCell"
                                              owner:self
                                            options:nil] objectAtIndex:0];
        //cell.imageView.image = [UIImage imageNamed:@"dayhotelicon.png"];
    }
    
    [cell setInfoItem:[self.activityItems objectAtIndex:indexPath.row]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView
 canPerformAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender
{
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView
    performAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender
{
    if (action == @selector(copy:)) {
        ZJUActivityListItem *item = [self.activityItems objectAtIndex:indexPath.row];
        
        [UIPasteboard generalPasteboard].string = [NSString stringWithFormat:
                                                   @"标题：%@\n"
                                                   @"时间：%@\n"
                                                   @"地点：%@\n",item.title,item.date,item.place];
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
    
    LectureDetailViewController *detail = [[LectureDetailViewController alloc] init];
    ZJUActivityListItem *item = [self.activityItems objectAtIndex:indexPath.row];
    detail.detailTitle = item.title;
    detail.ID = item.ID;
    [self.navigationController pushViewController:detail
                                         animated:YES];
}

#pragma mark - Actions

- (void)onMyFav:(id)sender
{
    LectureMyFavViewController *fav = [[LectureMyFavViewController alloc] init];
    [self.navigationController pushViewController:fav
                                         animated:YES];
}

- (IBAction)onLongPress:(UILongPressGestureRecognizer*)longPress
{
    CGPoint p = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
            [cell becomeFirstResponder];
            break;
        case UIGestureRecognizerStateEnded:
        {
            UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制"
                                                              action:@selector(copyItem:)];
            UIMenuItem *shareItem = [[UIMenuItem alloc] initWithTitle:@"分享"
                                                               action:@selector(shareItem:)];
            [[UIMenuController sharedMenuController] setMenuItems:@[copyItem,shareItem]];
            [[UIMenuController sharedMenuController] setTargetRect:cell.frame
                                                            inView:self.tableView];
            [[UIMenuController sharedMenuController] setMenuVisible:YES
                                                           animated:YES];
        }
            break;
        default:
            break;
    }
    
    
}


#pragma mark - ZJUDataRequest Delegate

- (void)requestDidFinished:(ZJUDataRequest *)request
                  withData:(id)data
{
    _request = nil;
    
    _activityItems = data;
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
}

- (void)requestDidFailed:(ZJUDataRequest *)request
               withError:(NSError *)error
{
    _request = nil;
    
    NSLog(@"%@",error);
    [SVProgressHUD showErrorWithStatus:@"矮油，貌似失败了...再试试啦"];
}

@end
