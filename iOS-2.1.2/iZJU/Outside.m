    //
    //  Outside.m
    //  iZJU
    //
    //  Created by 爱机 on 12-8-19.
    //  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
    //

#import "Outside.h"
#import "ViewController.h"
#import "ActivityDetail.h"
#import "SVProgressHUD.h"

@interface Outside ()
@property (nonatomic, strong) NSArray *outsideActivities;
@end

@implementation Outside

@synthesize tableView = _tableView, outsideActivities = _outsideActivities;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            // Custom initialization
        self.title = @"对外交流";
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

    self.tableView.backgroundColor = [UIColor clearColor];

    
    _request = [ZJUOutsideRequest dataRequest];
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

#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellbg.png"]];
        cell.backgroundView = bgImageView;
        cell.textLabel.font=[UIFont fontWithName:@"Arial" size:15];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ZJUOutsideListItem *item = [self.outsideActivities objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView 
numberOfRowsInSection:(NSInteger)section
{
    return self.outsideActivities.count;
}

-(NSInteger)tableView:(UITableView *)tableView 
sectionForSectionIndexTitle:(NSString *)title
              atIndex:(NSInteger)index
{
    return 1;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
    
    ActivityDetail *activity = [[ActivityDetail alloc] init];
    ZJUOutsideListItem *item = [self.outsideActivities objectAtIndex:indexPath.row];
    activity.ID = item.ID;
    activity.detailTitle = item.title;
    [self.navigationController pushViewController:activity
                                         animated:YES];
}

#pragma mark - Actions


#pragma mark - ZJUDateRequest delegate

- (void)requestDidFailed:(ZJUDataRequest *)request withError:(NSError *)error
{
    _request = nil;
    
    [SVProgressHUD showErrorWithStatus:@"加载失败！"];
}

- (void)requestDidFinished:(ZJUDataRequest *)request withData:(id)data
{
    _request = nil;
    
    _outsideActivities = data;
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
}

@end
