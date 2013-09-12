//
//  PopularTakeawayViewController.m
//  iZJU
//
//  Created by sheng tan on 12-10-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PopularTakeawayViewController.h"
#import "PopularTakeawayTableCell.h"
#import "PopularTakeawayDetailViewController.h"
#import "ZJUDataServer.h"
#import "ZJUPopularTakeawayRequest.h"
#import "SVProgressHUD.h"

@implementation PopularTakeawayViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"热门外卖";
    }
    return self;
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIImageView *tablebg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commonbg.jpg"]];
    self.tableView.backgroundView = tablebg;
    
    CGFloat headerHeight = self.tableView.tableHeaderView.bounds.size.height;
    self.tableView.contentOffset = CGPointMake(0, headerHeight);
    
    ZJUPopularTakeawayRequest *request = [ZJUPopularTakeawayRequest dataRequest];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView)
        return takeawayProducts.count;
    else
        return filteredProducts.count;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
        return 64.0f;
    else
        return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        static NSString *CellIdentifier = @"PopularTakeawayCell";
        
        PopularTakeawayTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PopularTakeawayTableCell"
                                                  owner:self
                                                options:nil] objectAtIndex:0];
        }
        // Configure the cell...
        ZJUPopularTakeawayItem *item = [takeawayProducts objectAtIndex:indexPath.row];
        
        NSString *phoneString = @"";
        NSString *mobile = nil, *phone = nil;
        if (![NSString isNullOrEmpty:(mobile = item.mobileNum)] &&
            ![NSString isNullOrEmpty:(phone = item.phoneNum)]) {
            phoneString = [NSString stringWithFormat:@"%@/%@",mobile,phone];
        }
        else if (![NSString isNullOrEmpty:mobile]) {
            phoneString = mobile;
        }
        else if (![NSString isNullOrEmpty:(phone = item.phoneNum)]) {
            phoneString = phone;
        }
        [cell setCellInfoWithName:item.shopName
                              tel:phoneString
                         delivery:item.condition
                            other:item.remark];
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"SearchResultCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
        }
        ZJUPopularTakeawayItem *item = [filteredProducts objectAtIndex:indexPath.row];
        cell.textLabel.text = item.shopName;
        return cell;
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        PopularTakeawayDetailViewController *detailController = [[PopularTakeawayDetailViewController alloc] init];
        ZJUPopularTakeawayItem *item = [takeawayProducts objectAtIndex:indexPath.row];
        detailController.title = item.shopName;
        detailController.productsArray = item.dishes;
        PopularTakeawayTableCell *cell = (PopularTakeawayTableCell*)[tableView cellForRowAtIndexPath:indexPath];
        detailController.numbers = cell.restaurantTel.text;
        [self.navigationController pushViewController:detailController
                                             animated:YES];
    }
    else {
        [self.searchDisplayController setActive:NO
                                       animated:YES];
        
        NSUInteger index = [takeawayProducts indexOfObject:[filteredProducts objectAtIndex:indexPath.row]];
        if (index != NSNotFound) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                    inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}


#pragma mark - UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText
{
    if (![NSString isNullOrEmpty:searchText]) {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"shopName contains %@",searchText];
        filteredProducts = [takeawayProducts filteredArrayUsingPredicate:filter];
    }
}


#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [AppHelper makeACallTo:[actionSheet buttonTitleAtIndex:buttonIndex]];
    }
}

#pragma mark - PopularTakeawayCell Delegate

- (void)PopularTakeawayCellCall:(PopularTakeawayTableCell *)cell
{
    NSString *title = [NSString stringWithFormat:@"%@: %@",cell.restaurantName.text,cell.restaurantTel.text];
    NSString *tel = cell.restaurantTel.text;
    if ([NSString isNullOrEmpty:tel]) {
        [SVProgressHUD showErrorWithStatus:@"木有电话哦，亲T_T"];
        return;
    }
    [[AppHelper sharedHelper] showCallerSheetWithTitle:title
                                                number:tel];
}

#pragma mark - ZJUDataRequest Delegate

- (void)requestDidFinished:(ZJUDataRequest *)request
                  withData:(id)data
{
    [SVProgressHUD dismiss];
    takeawayProducts = data;
    [self.tableView reloadData];
}

- (void)requestDidFailed:(ZJUDataRequest *)request
               withError:(NSError *)error
{
    NSLog(@"%@",error);
    [SVProgressHUD showErrorWithStatus:@"矮油，貌似失败了...再试试啦"];
}

@end
