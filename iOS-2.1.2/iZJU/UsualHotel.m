//
//  UsualHotel.m
//  iZJU
//
//  Created by 爱机 on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UsualHotel.h"
#import "ZJUDataServer.h"
#import "ZJUHotelRequest.h"
#import "SVProgressHUD.h"

@interface UsualHotel ()

@end

@implementation UsualHotel
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"住宿";
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
    
    ZJUHotelRequest *request = [ZJUHotelRequest dataRequest];
    [[ZJUDataServer sharedServer] executeRequest:request
                                        delegate:self];
    [SVProgressHUD showWithStatus:@"加载中..."];
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
    return _hotels.count;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"Cell"];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellbg.png"]];
        cell.backgroundView = bg;
    }
    
    NSDictionary *info = [_hotels objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [info valueForKey:@"name"];
    cell.detailTextLabel.text = [info valueForKey:@"contact"];

    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *number = [[_hotels objectAtIndex:indexPath.row] valueForKey:@"contact"];
    [[AppHelper sharedHelper] showCallerSheetWithTitle:@"拨打电话"
                                                number:number];
}

#pragma mark - UIActionSheet Delegate



#pragma mark - ZJUDataRequest Delegate

- (void)requestDidFinished:(ZJUDataRequest *)request
                  withData:(id)data
{
    [SVProgressHUD dismiss];
    _hotels = data;
    [self.tableView reloadData];
}

- (void)requestDidFailed:(ZJUDataRequest *)request
               withError:(NSError *)error
{
    NSLog(@"%@",error);
    [SVProgressHUD showErrorWithStatus:@"矮油，貌似失败了...再试试啦"];
}

@end
