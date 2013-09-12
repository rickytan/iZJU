    //
    //  Emcall.m
    //  iZJU
    //
    //  Created by 爱机 on 12-8-19.
    //  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
    //

#import "DayHoltel.h"
#import "ZJUDataServer.h"
#import "ZJUDailyRentRequest.h"
#import "SVProgressHUD.h"


@implementation DayHoltel;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            // Custom initialization
        self.title = @"日租";
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

    ZJUDailyRentRequest *request = [ZJUDailyRentRequest dataRequest];
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

#pragma mark - TableView

-(void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *number = [[_hotels objectAtIndex:indexPath.row] valueForKey:@"contact"];
    [[AppHelper sharedHelper] showCallerSheetWithTitle:@"拨打电话"
                                                number:number];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:CellIdentifier];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellbg.png"]];
        cell.backgroundView = bg;
    }
    
    NSDictionary *info = [_hotels objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [info valueForKey:@"name"];
    cell.detailTextLabel.text = [info valueForKey:@"contact"];
    
    return cell;
}

-(float)tableView:(UITableView *)tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

-(NSInteger)tableView:(UITableView *)tableView 
numberOfRowsInSection:(NSInteger)section
{
    
    return _hotels.count;
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
