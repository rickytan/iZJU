//
//  ActivityDetailViewController.m
//  iZJU
//
//  Created by 爱机 on 12-9-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ActivityDetail.h"
#import "ActivityDetailCell.h"
#import "SVProgressHUD.h"

@interface ActivityDetail ()

@end

@implementation ActivityDetail
@synthesize tableView = _tableView;
@synthesize detailTitle = _detailTitle;
@synthesize detailTitleLabel = _detailTitleLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        self.title = @"详情";
    }
    return self;
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *text = self.detailTitle;
    /*
    CGSize size = CGSizeMake(284, MAXFLOAT);
    UIFont *font = [UIFont systemFontOfSize:17];
    size = [text sizeWithFont:font 
            constrainedToSize:size
                lineBreakMode:UILineBreakModeWordWrap];
    size.height = MAX(size.height + 27, 49);
    
    self.tableView.tableHeaderView.frame = CGRectMake(0, 0, size.width, size.height);
     */
    self.detailTitleLabel.text = text;

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"outsidenavbar.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_detailInfo)
        return;
    
    _request = [ZJUOutsideDetailRequest dataRequest];
    _request.ID = self.ID;
    [[ZJUDataServer sharedServer] executeRequest:_request
                                        delegate:self];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setStatus:@"加载中..."];
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

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return _detailInfo.count;
}

- (CGFloat)tableView:(UITableView *)tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    NSString *text = [[_detailInfo objectAtIndex:row] valueForKey:@"value"];
    CGSize size = CGSizeMake(210, MAXFLOAT);
    UIFont *font = [UIFont systemFontOfSize:12];
    size = [text sizeWithFont:font 
            constrainedToSize:size
                lineBreakMode:UILineBreakModeWordWrap];
    return MAX(size.height + 22, 44);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActivityDetailCell";
    ActivityDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        NSArray *a = [[NSBundle mainBundle] loadNibNamed:@"ActivityDetailCell"
                                                   owner:self
                                                 options:nil];
        for (id obj in a) {
            if ([obj isKindOfClass:[ActivityDetailCell class]]) {
                cell = (ActivityDetailCell*)obj;
                break;
            }
        }
    }
    
    cell.backgroundColor = [UIColor yellowColor];
    
    int index = [indexPath row];
    NSDictionary *data = [_detailInfo objectAtIndex:index];
    cell.content.text = [data valueForKey:@"value"];
    cell.title.text = [[data valueForKey:@"key"] stringByAppendingString:@"："];
    /*
    switch (index) {
        case 0:
            cell.title.text = @"报名时间：";
            break;
        case 1:
            cell.title.text = @"交流时间：";
            break;
        case 2:
            cell.title.text = @"简介：";
            break;
        case 3:
            cell.title.text = @"选拔条件：";
            break;
        case 4:
            cell.title.text = @"费用：";
            break;
        default:
            break;
    }
     */
    // Configure the cell...
    
    return cell;
}


#pragma mark - ZJUDate delegate

- (void)requestDidFailed:(ZJUDataRequest *)request
               withError:(NSError *)error
{
    _request = nil;
    [SVProgressHUD showErrorWithStatus:@"矮油，貌似失败了...再试试啦"];
}

- (void)requestDidFinished:(ZJUDataRequest *)request withData:(id)data
{
    _request = nil;
    
    ZJUOutsideDetailItem *item = (ZJUOutsideDetailItem*)data;
    _detailInfo = item.details;
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
}

@end
