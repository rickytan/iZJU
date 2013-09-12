//
//  FavoritePhoneController.m
//  iZJU
//
//  Created by ricky on 13-1-25.
//
//

#import "FavoritePhoneController.h"
#import "YellowPageViewController.h"
#import "FMDatabase.h"
#import "Telephone.h"
#import "SVProgressHUD.h"

@interface FavoritePhoneController ()
@property (nonatomic, strong) NSMutableArray *favoritePhone;
@property (nonatomic, strong) NSMutableArray *favoritePhoneItems;
- (void)queryFavoritePhoneItem;
@end

@implementation FavoritePhoneController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.favoritePhoneItems = [NSMutableArray arrayWithCapacity:10];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.favoritePhone = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:iZJUUserFavoritePhoneKey];
    
    [self performSelectorInBackground:@selector(queryFavoritePhoneItem)
                           withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)queryFavoritePhoneItem
{
    FMDatabase *_db = [FMDatabase databaseWithPath:[Telephone telephoneDBPath]];
    if ([_db open]) {
        NSString *ids = [self.favoritePhone componentsJoinedByString:@","];
        NSString *query = [NSString stringWithFormat:@"SELECT id,title,is_leaf FROM Node WHERE id in (%@)",ids];
        FMResultSet *result = [_db executeQuery:query];
        [self.favoritePhoneItems removeAllObjects];
        while ([result next]) {
            PhoneItem *item = [[PhoneItem alloc] init];
            item.ID = [result intForColumn:@"id"];
            item.title = [result stringForColumn:@"title"];
            item.leaf = [result boolForColumn:@"is_leaf"];
            
            if (item.isLeaf) {
                NSMutableArray *nums = [NSMutableArray arrayWithCapacity:10];
                FMResultSet *numresult = [_db executeQueryWithFormat:@"SELECT number FROM Number WHERE nid = %d",item.ID];
                while ([numresult next]) {
                    [nums addObject:[numresult stringForColumn:@"number"]];
                }
                item.numbers = [NSArray arrayWithArray:nums];
            }
            [self.favoritePhoneItems addObject:item];
        }
        [_db close];
        _db = nil;
        [self.tableView reloadData];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"数据库打开失败！"];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.favoritePhoneItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[YellowPageViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    PhoneItem *item = [self.favoritePhoneItems objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = [item.numbers componentsJoinedByString:@"/"];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhoneItem *item = [self.favoritePhoneItems objectAtIndex:indexPath.row];
    
    return item.isLeaf;
}

- (BOOL)tableView:(UITableView *)tableView
 canPerformAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender
{
    return action == @selector(copy:) || action == @selector(sendSMS:);
}

- (void)tableView:(UITableView *)tableView
    performAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender
{
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        PhoneItem *item = [self.favoritePhoneItems objectAtIndex:indexPath.row];
        [self.favoritePhone removeObject:[NSNumber numberWithInt:item.ID]];
        [self.favoritePhoneItems removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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
    PhoneItem *item = [self.favoritePhoneItems objectAtIndex:indexPath.row];
    
    if (item.isLeaf) {
        [tableView deselectRowAtIndexPath:indexPath
                                 animated:YES];
        NSString *number = [item.numbers componentsJoinedByString:@"/"];
        [[AppHelper sharedHelper] showCallerSheetWithTitle:item.title
                                                    number:number];
        
        return;
    }
}

@end
