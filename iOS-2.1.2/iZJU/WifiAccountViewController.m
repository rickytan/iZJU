//
//  WifiAccountViewController.m
//  iZJU
//
//  Created by ricky on 12-12-20.
//
//

#import "WifiAccountViewController.h"
#import "Wifi.h"

enum {
    kUIAlertViewAddingTag = 102,
    kUIAlertViewModifyTag
};

@interface WifiAccountViewController ()
- (void)showAddingAlertView;
- (void)showModifyAlertViewWithAccount:(NSDictionary*)info;
@end

@implementation WifiAccountViewController

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
        self.title = @"帐号管理";
        accounts = [Wifi getSavedAccounts];
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if ([Wifi getSavedAccounts].count == 0) {
        [self showAddingAlertView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)showAddingAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入帐号信息："
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert textFieldAtIndex:0].placeholder = @"帐号";
    alert.tag = kUIAlertViewAddingTag;
    [alert show];
}

- (void)showModifyAlertViewWithAccount:(NSDictionary *)info
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入帐号信息："
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert textFieldAtIndex:0].placeholder = @"帐号";
    alert.tag = kUIAlertViewModifyTag;
    [alert textFieldAtIndex:0].text = [info valueForKey:@"username"];
    [alert textFieldAtIndex:1].text = [info valueForKey:@"password"];
    [alert show];
}

#pragma mark - UIAlert Delegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    return [alertView textFieldAtIndex:0].text.length > 0 && [alertView textFieldAtIndex:1].text.length > 0;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        if (alertView.tag == kUIAlertViewAddingTag) {
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [alertView textFieldAtIndex:0].text,@"username",
                                  [alertView textFieldAtIndex:1].text,@"password", nil];
            if ([Wifi saveAccount:info]) {
                accounts = [Wifi getSavedAccounts];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:accounts.count-1
                                                                            inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        else if (alertView.tag == kUIAlertViewModifyTag) {
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [alertView textFieldAtIndex:0].text,@"username",
                                  [alertView textFieldAtIndex:1].text,@"password", nil];
            if ([Wifi updateAccount:info
                            atIndex:modifingIndex]) {
                accounts = [Wifi getSavedAccounts];
                [self.tableView reloadData];
            }
        }
    }
    modifingIndex = NSNotFound;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.navigationItem setHidesBackButton:editing
                                   animated:animated];
    if (editing)
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:accounts.count
                                                                    inSection:0]]
                              withRowAnimation:UITableViewRowAnimationRight];
    else
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:accounts.count
                                                                    inSection:0]]
                              withRowAnimation:UITableViewRowAnimationRight];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return accounts.count + (self.isEditing?1:0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell...
    if (indexPath.row == accounts.count) {
        cell.textLabel.text = @"添加新帐号";
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        NSDictionary *info = [accounts objectAtIndex:indexPath.row];
        cell.textLabel.text = [info valueForKey:@"username"];
        NSString *pass = [info valueForKey:@"password"];
        cell.detailTextLabel.text = [pass stringByReplaceStringWithChar:'*'];
        cell.accessoryType = (indexPath.row == [Wifi defaultAccountIndex])?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row == accounts.count)?UITableViewCellEditingStyleInsert:UITableViewCellEditingStyleDelete;
}


// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if ([Wifi deleteAccountAtIndex:indexPath.row]) {
            accounts = [Wifi getSavedAccounts];
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        [self showAddingAlertView];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != accounts.count) {
        if (self.isEditing) {
            modifingIndex = indexPath.row;
            NSDictionary *info = [accounts objectAtIndex:modifingIndex];
            [self showModifyAlertViewWithAccount:info];
        }
        else {
            [Wifi setDefaultAccountIndex:indexPath.row];
            [self.tableView reloadData];
        }
    }
}

@end
