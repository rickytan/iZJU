//
//  SchoolbusSpecifiedBusViewController.m
//  iZJU
//
//  Created by ricky on 12-11-16.
//
//

#import "SchoolBusSpecifiedBusViewController.h"
#import "SchoolBusSpecifiedBusResultCell.h"
#import "SchoolBusDetailViewController.h"

@interface SchoolBusSpecifiedBusViewController ()

@end

@implementation SchoolBusSpecifiedBusViewController

@synthesize results = _results;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commonbg.jpg"]];
    self.tableView.backgroundView = bg;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter & setter

- (void)setResults:(NSArray *)results
{
    _results = results;
    if (_results.count == 0)
        self.tableView.allowsSelection = NO;
    else
        self.tableView.allowsSelection = YES;
    
    [self.tableView reloadData];
}

#pragma mark - Actions


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (self.results.count == 0)
        return 13;
    return self.results.count;
}

- (UIView*)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SchoolBusSpecifiedBusResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([SchoolBusSpecifiedBusResultCell class])
                                              owner:self
                                            options:nil] objectAtIndex:0];
    }
    
    // Configure the cell...
    if (self.results.count == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 3)
        {
            cell.textLabel.text = @"没有结果！";
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.textColor = [UIColor darkTextColor];
        }
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        [cell setupInfo:[self.results objectAtIndex:indexPath.row]];
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
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    if (self.results.count == 0)
        return;
    
    SchoolBusDetailViewController *detailViewController = [[SchoolBusDetailViewController alloc] init];
    detailViewController.item = [self.results objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailViewController
                                         animated:YES];
}

@end
