//
//  YellowPageViewController.m
//  iZJU
//
//  Created by ricky on 12-12-14.
//
//

#import "YellowPageViewController.h"
#import "Telephone.h"
#import "AppHelper.h"
#import <MessageUI/MessageUI.h>
#import "TKAlertCenter.h"

@interface YellowPageViewCell () <MFMessageComposeViewControllerDelegate>

@end

@implementation YellowPageViewCell
@synthesize favButton = _favButton;
@synthesize phoneItem = _phoneItem;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.favButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.favButton.frame = CGRectMake(0, 0, 20, 18);
        [self.favButton setBackgroundImage:[UIImage imageNamed:@"fav_normal.png"]
                                  forState:UIControlStateNormal];
        [self.favButton setBackgroundImage:[UIImage imageNamed:@"fav_highlight.png"]
                                  forState:UIControlStateSelected];
        [self.favButton addTarget:self
                           action:@selector(onFavButton:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)onFavButton:(id)sender
{
    NSMutableArray *arr = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:iZJUUserFavoritePhoneKey];
    if (self.favButton.isSelected) {    // 取消收藏
        [arr removeObject:[NSNumber numberWithInt:self.phoneItem.ID]];
    }
    else {
        if (!arr) {
            arr = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:self.phoneItem.ID]];
            [[NSUserDefaults standardUserDefaults] setObject:arr
                                                      forKey:iZJUUserFavoritePhoneKey];
        }
        else {
            NSNumber *num = [NSNumber numberWithInt:self.phoneItem.ID];
            if (![arr containsObject:num]) {
                [arr addObject:num];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    self.favButton.selected = !self.favButton.isSelected;
}

- (void)setPhoneItem:(PhoneItem *)item
{
    if (_phoneItem == item)
        return;
    _phoneItem = item;
    
    self.textLabel.text = item.title;
    
    if (item.isLeaf) {
        self.detailTextLabel.text = [item.numbers componentsJoinedByString:@"/"];
    }
    else {
        self.detailTextLabel.text = nil;
    }
    
    if (item.hasChild) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.accessoryView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.accessoryView = self.favButton;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (PhoneItem*)phoneItem
{
    return _phoneItem;
}


- (void)setFavorite:(BOOL)favorite
{
    self.favButton.selected = favorite;
}

- (BOOL)isFavorite
{
    return self.favButton.isSelected;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return action == @selector(copy:) || action == @selector(sendSMS:);
}

- (void)sendSMS:(id)sender
{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *smsController = [[MFMessageComposeViewController alloc] init];
        NSString *text = [NSString stringWithFormat:@"[部门]:%@\n[电话]:%@",self.textLabel.text,self.detailTextLabel.text];
        smsController.body = text;
        smsController.messageComposeDelegate = self;
        UIViewController *controller = nil;
        UIResponder *resp = self.nextResponder;
        while (resp) {
            if ([resp isKindOfClass:UIViewController.class]) {
                controller = (UIViewController*)resp;
                break;
            }
            resp = resp.nextResponder;
        }
        if (!controller) {
            controller = self.window.rootViewController;
        }
        [controller presentModalViewController:smsController
                                      animated:YES];
    }
    else {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"您的设备不支持短信！"];
    }
}

- (void)copy:(id)sender
{
    NSString *text = [NSString stringWithFormat:@"[部门]:%@\n[电话]:%@",self.textLabel.text,self.detailTextLabel.text];
    [[UIPasteboard generalPasteboard] setString:text];
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"已复制！"];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissModalViewControllerAnimated:YES];
}

@end

@interface YellowPageViewController ()
@property (nonatomic, strong) NSArray *favoritePhone;
- (void)queryPhoneItems;
- (void)loadDataInBackground;
- (void)loadDidFinished;
@end

@implementation YellowPageViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"短信发送"
                                                  action:@selector(sendSMS:)];
    menuController.menuItems = @[item];
    [menuController update];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.favoritePhone = [[NSUserDefaults standardUserDefaults] arrayForKey:iZJUUserFavoritePhoneKey];
    [self loadDataInBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)queryPhoneItems
{
    if (!_database) {
        _database = [FMDatabase databaseWithPath:[Telephone telephoneDBPath]];
        if (![_database open]) {
            [_database close];
            _database = nil;
        }
    }
    
    FMResultSet *result = [_database executeQueryWithFormat:@"SELECT id,pid,title,has_child,is_leaf FROM Node WHERE pid = %d",self.parentID];
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:10];
    while ([result next]) {
        PhoneItem *item = [[PhoneItem alloc] init];
        item.ID = [result intForColumn:@"id"];
        item.pID = [result intForColumn:@"pid"];
        item.title = [result stringForColumn:@"title"];
        item.hasChild = [result boolForColumn:@"has_child"];
        item.leaf = [result boolForColumn:@"is_leaf"];
        
        if (item.isLeaf) {
            NSMutableArray *nums = [NSMutableArray arrayWithCapacity:10];
            FMResultSet *numresult = [_database executeQueryWithFormat:@"SELECT number FROM Number WHERE nid = %d",item.ID];
            while ([numresult next]) {
                [nums addObject:[numresult stringForColumn:@"number"]];
            }
            item.numbers = [NSArray arrayWithArray:nums];
        }
        [data addObject:item];
    }
    self.phoneNumbers = [NSArray arrayWithArray:data];
    
    [self performSelectorOnMainThread:@selector(loadDidFinished)
                           withObject:nil
                        waitUntilDone:NO];
}

- (void)loadDataInBackground
{
    [self performSelectorInBackground:@selector(queryPhoneItems)
                           withObject:nil];
}

- (void)loadDidFinished
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.phoneNumbers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    YellowPageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[YellowPageViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    PhoneItem *item = [self.phoneNumbers objectAtIndex:indexPath.row];
    [cell setPhoneItem:item];
    NSNumber *num = [NSNumber numberWithInt:item.ID];
    cell.favorite = [self.favoritePhone containsObject:num];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhoneItem *item = [self.phoneNumbers objectAtIndex:indexPath.row];
    
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
    PhoneItem *item = [self.phoneNumbers objectAtIndex:indexPath.row];
    
    if (item.isLeaf) {
        [tableView deselectRowAtIndexPath:indexPath
                                 animated:YES];
        NSString *number = [item.numbers componentsJoinedByString:@"/"];
        [[AppHelper sharedHelper] showCallerSheetWithTitle:item.title
                                                    number:number];
        
        return;
    }
    
    YellowPageViewController *detailViewController = [[YellowPageViewController alloc] init];
    // ...
    // Pass the selected object to the new view controller.
    detailViewController.parentID = item.ID;
    detailViewController.title = item.title;
    [self.navigationController pushViewController:detailViewController
                                         animated:YES];
}

@end
