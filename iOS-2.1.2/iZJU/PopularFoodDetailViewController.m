//
//  PopularFoodDetailViewController.m
//  iZJU
//
//  Created by sheng tan on 12-10-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PopularFoodDetailViewController.h"

@implementation PopularFoodDetailViewController
@synthesize detailInfo = _detailInfo;

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 5;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.minimumFontSize = 10;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        if ([cell.detailTextLabel respondsToSelector:@selector(setAdjustsLetterSpacingToFitWidth:)])
            cell.detailTextLabel.adjustsLetterSpacingToFitWidth = YES;
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"地址：";
                    cell.detailTextLabel.text = [self.detailInfo valueForKey:@"Address"];
                    break;
                case 1:
                {
                    cell.textLabel.text = @"电话：";
                    NSString *phone = [self.detailInfo valueForKey:@"Telephone"];
                    if (phone && ![phone isEqualToString:@""]) {
                        cell.detailTextLabel.text = [self.detailInfo valueForKey:@"Telephone"];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"人均：";
                    cell.detailTextLabel.text = [self.detailInfo valueForKey:@"Average"];
                    break;
                case 1:
                    cell.textLabel.text = @"推荐菜：";
                    cell.detailTextLabel.text = [self.detailInfo valueForKey:@"Recommend"];
                    break;
                case 2:
                    cell.textLabel.text = @"优惠：";
                    cell.detailTextLabel.text = [self.detailInfo valueForKey:@"Discount"];
                    break;
                case 3:
                    cell.textLabel.text = @"聚餐规模：";
                    cell.detailTextLabel.text = [self.detailInfo valueForKey:@"Scale"];
                    break;
                case 4:
                    cell.textLabel.text = @"备注：";
                    cell.detailTextLabel.text = [self.detailInfo valueForKey:@"Userinfo"];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    return cell;
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

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSString *tel = [actionSheet buttonTitleAtIndex:buttonIndex];
        [AppHelper makeACallTo:tel];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 &&
        indexPath.row == 1 &&
        [self.detailInfo valueForKey:@"Telephone"] &&
        ![[self.detailInfo valueForKey:@"Telephone"] isEqualToString:@""]) {
        [tableView deselectRowAtIndexPath:indexPath
                                 animated:YES];
        
        NSString *tel = [self.detailInfo valueForKey:@"Telephone"];
        [[AppHelper sharedHelper] showCallerSheetWithTitle:[@"电话：" stringByAppendingString:tel]
                                                    number:tel];
    }
}

@end
