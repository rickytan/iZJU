//
//  PopularFoodViewController.m
//  iZJU
//
//  Created by sheng tan on 12-10-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PopularFoodViewController.h"
#import "PopularFoodTableCell.h"
#import "PopularFoodDetailViewController.h"
#import "ZJUDataServer.h"
#import "ZJUPopularFoodRequest.h"

@interface PopularFoodViewController ()

@end

@implementation PopularFoodViewController
@synthesize categoryBtn = _categoryBtn;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"热门美食";
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
        self.title = @"热门美食";
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
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.categoryBtn;
    
    UIImageView *tablebg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commonbg.jpg"]];
    self.tableView.backgroundView = tablebg;
    CGFloat headerHeight = self.tableView.tableHeaderView.bounds.size.height;
    self.tableView.contentOffset = CGPointMake(0, headerHeight);
    
    ZJUPopularFoodRequest *schools = [ZJUPopularFoodRequest dataRequest];
    [[ZJUDataServer sharedServer] executeRequest:schools
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

#pragma mark - getter & setter


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        return 89.0f;
    }
    else {
        return 44.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView)
        return (currentCategory && ![currentCategory isEqualToString:@""])?24.0f:0.0f;
    else
        return 0.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView)
        return categoriedProducts.count;
    else
        return filteredProducts.count;
}

//- (UIView*)tableView:(UITableView *)tableView
//viewForHeaderInSection:(NSInteger)section
//{
//    return sectionHeader;
//}

- (NSString*)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView)
        return currentCategory;
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        static NSString *CellIdentifier = @"PopularFoodCell";
        
        PopularFoodTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PopularFoodTableCell class])
                                                  owner:self
                                                options:nil] objectAtIndex:0];
        }
        // Configure the cell...
        ZJUFoodItem *item = [categoriedProducts objectAtIndex:indexPath.row];
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
                             addr:item.address
                         category:item.category
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
        ZJUFoodItem *item = [filteredProducts objectAtIndex:indexPath.row];
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
    // Navigation logic may go here. Create and push another view controller.
    if (tableView == self.tableView) {
        ZJUFoodItem *data = [categoriedProducts objectAtIndex:indexPath.row];
        
        PopularFoodDetailViewController *detailViewController = [[PopularFoodDetailViewController alloc] init];
        
        detailViewController.title = data.shopName;
        
        NSString *phoneString = @"";
        NSString *mobile = nil, *phone = nil;
        if (![NSString isNullOrEmpty:(mobile = data.mobileNum)] &&
            ![NSString isNullOrEmpty:(phone = data.phoneNum)]) {
            phoneString = [NSString stringWithFormat:@"%@/%@",mobile,phone];
        }
        else if (![NSString isNullOrEmpty:mobile]) {
            phoneString = mobile;
        }
        else if (![NSString isNullOrEmpty:(phone = data.phoneNum)]) {
            phoneString = phone;
        }
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                              phoneString,@"Telephone",
                              data.address,@"Address",
                              data.price,@"Average",
                              data.recomand,@"Recommend",
                              data.discount,@"Discount",
                              data.scale,@"Scale",
                              data.remark,@"Userinfo", nil];
        detailViewController.detailInfo = info;
        
        [self.navigationController pushViewController:detailViewController
                                             animated:YES];
    }
    else {
        [self.searchDisplayController setActive:NO
                                       animated:YES];
        
        NSUInteger index = [categoriedProducts indexOfObject:[filteredProducts objectAtIndex:indexPath.row]];
        if (index != NSNotFound) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                    inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

#pragma mark - FoodCategory Delegate

- (void)FoodCategoryDidSelectCategory:(NSString *)category
{
    currentCategory = category;
    if (currentCategory) {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"category == %@",currentCategory];
        categoriedProducts = [foodProducts filteredArrayUsingPredicate:filter];
    }
    else {
        categoriedProducts = foodProducts;
    }
    [self.tableView reloadData];
}

#pragma mark - Actions

- (IBAction) categoryPressed:(id)sender
{
    [self.searchDisplayController setActive:NO];
    
    FoodCategoryViewController *foodCategoryController = [[FoodCategoryViewController alloc] init];
    foodCategoryController.delegate = self;
    
    NSMutableArray *categories = [NSMutableArray arrayWithCapacity:8];
    for (ZJUFoodItem *item in foodProducts) {
        NSString *cate = item.category;
        if (![categories containsObject:cate])
            [categories addObject:cate];
    }
    
    foodCategoryController.categories = categories;
    foodCategoryController.selectedCategory = currentCategory;
    [self.navigationController pushViewController:foodCategoryController
                                         animated:YES];
}

#pragma mark - UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText
{
    if (searchText && ![searchText isEqualToString:@""]) {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"shopName contains %@",searchText];
        filteredProducts = [categoriedProducts filteredArrayUsingPredicate:filter];
    }
}

#pragma mark - ZJUDataRequest Delegate

- (void)requestDidFinished:(ZJUDataRequest *)request
                  withData:(id)data
{
    [SVProgressHUD dismiss];
    foodProducts = data;
    categoriedProducts = foodProducts;
    currentCategory = nil;
    [self.tableView reloadData];
}

- (void)requestDidFailed:(ZJUDataRequest *)request
               withError:(NSError *)error
{
    NSLog(@"%@",error);
    [SVProgressHUD showErrorWithStatus:@"矮油，貌似失败了...再试试啦."];
}

@end
