//
//  SearchPhoneController.m
//  iZJU
//
//  Created by ricky on 13-1-25.
//
//

#import "SearchPhoneController.h"
#import "FMDatabase.h"
#import "ZipArchive.h"
#import "Telephone.h"
#import "SVProgressHUD.h"
#import "YellowPageViewController.h"

@interface SearchPhoneController ()
{
    FMDatabasePool          * _databasePool;
    
    NSCache                 * _queryCache;
    
    NSMutableArray          * _filteredPhone;
    NSOperationQueue        * _operationQueue;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (atomic, strong) NSMutableArray *filteredPhone;
@property (nonatomic, strong) NSArray *favoritePhone;
- (void)searchWithText:(NSString*)text;
- (void)searchWithTextInBackground:(NSString *)text;
- (void)searchExcuteQuery:(NSString*)query;
- (void)searchDidFinished;
@end

@implementation SearchPhoneController
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;
@synthesize filteredPhone = _filteredPhone;
@synthesize favoritePhone = _favoritePhone;

- (void)dealloc
{
    [_databasePool releaseAllDatabases];
    _databasePool = nil;
    [_operationQueue cancelAllOperations];
    _operationQueue = nil;
    [_queryCache removeAllObjects];
    _queryCache = nil;
    
    self.tableView = nil;
    self.searchBar = nil;
    
    self.filteredPhone = nil;
    self.favoritePhone = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.searchBar setBackgroundImage:[UIImage imageNamed:@"outsidenavbar.png"]];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"短信发送"
                                                  action:@selector(sendSMS:)];
    menuController.menuItems = @[item];
    [menuController update];
    
    [self initSQLite];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.favoritePhone = [[NSUserDefaults standardUserDefaults] arrayForKey:iZJUUserFavoritePhoneKey];
    [self.navigationController setNavigationBarHidden:YES
                                             animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.presentedViewController)
        return;
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)initSQLite
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [Telephone telephoneDBPath];
    if (![fm fileExistsAtPath:path]) {
        NSString *dbResource = [[NSBundle mainBundle] pathForResource:@"zjutel-db"
                                                               ofType:@"zip"];
        ZipArchive *zip = [[ZipArchive alloc] init];
        if (![zip UnzipOpenFile:dbResource Password:@"IloveiZJU!123"]) {
            NSLog(@"数据文件打开错误！");
        }
        if (![zip UnzipFileTo:[path stringByDeletingLastPathComponent]
                    overWrite:YES]) {
            NSLog(@"数据文件解压错误！");
        }
        [zip UnzipCloseFile];
    }
    
    _databasePool = [FMDatabasePool databasePoolWithPath:path];
    if (_databasePool) {
        [self performSelectorOnMainThread:@selector(initDidFinished)
                               withObject:nil
                            waitUntilDone:NO];
    }
    
}

- (void)initDidFinished
{
    self.filteredPhone = [NSMutableArray arrayWithCapacity:50];
    _queryCache = [[NSCache alloc] init];
    [self searchWithText:nil];
}

- (void)searchWithText:(NSString*)text
{
    self.tableView.userInteractionEnabled = NO;
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self
                                                                     selector:@selector(searchWithTextInBackground:)
                                                                       object:text];
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    
    [_operationQueue addOperation:op];
    
}

- (void)searchWithTextInBackground:(NSString *)text
{
    if ([NSString isNullOrEmpty:text]) {
        [self searchExcuteQuery:@"SELECT id,pid,title,has_child,is_leaf FROM Node WHERE 1 LIMIT 0,50"];
    }
    else {
        NSArray *arr = [text componentsSeparatedByString:@" "];
        NSString *text = [arr componentsJoinedByString:@"%"];
        NSString *numeric = @"%";
        BOOL hasNumber = NO;
        for (NSString *s in arr) {
            if ([s integerValue]) {
                hasNumber = YES;
                numeric = [numeric stringByAppendingFormat:@"%@%%",s];
            }
        }
        if (hasNumber) {
            NSString *sql = @"SELECT id,pid,title,has_child,is_leaf "
            @"FROM Node "
            @"WHERE title like \"%%%@%%\" OR "
            @"id IN (SELECT nid FROM Number WHERE number like \"%@\") "
            @"LIMIT 0,50";
            [self searchExcuteQuery:[NSString stringWithFormat:sql,text,numeric]];
        }
        else {
            NSString *sql = @"SELECT id,pid,title,has_child,is_leaf "
            @"FROM Node "
            @"WHERE title like \"%%%@%%\" "
            @"LIMIT 0,50";
            [self searchExcuteQuery:[NSString stringWithFormat:sql,text]];
        }
        
    }
}

- (void)searchExcuteQuery:(NSString *)query
{
    @synchronized(self) {
        NSArray *arr = [_queryCache objectForKey:query];
        if (arr) {
            [self.filteredPhone setArray:arr];
        }
        else {
            [_databasePool inDatabase:^(FMDatabase *_database) {
                FMResultSet *result = [_database executeQuery:query];
                [self.filteredPhone removeAllObjects];
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
                    [self.filteredPhone addObject:item];
                }
                [_queryCache setObject:[NSArray arrayWithArray:self.filteredPhone]
                                forKey:query];
            }];
        }
        [self performSelectorOnMainThread:@selector(searchDidFinished)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

- (void)searchDidFinished
{
    [self.tableView reloadData];
    self.tableView.userInteractionEnabled = _operationQueue.operationCount == 1;
}

#pragma mark - UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchWithText:searchText];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.filteredPhone.count;
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
    PhoneItem *item = [self.filteredPhone objectAtIndex:indexPath.row];
    cell.phoneItem = item;
    cell.favorite = [self.favoritePhone containsObject:[NSNumber numberWithInt:item.ID]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhoneItem *item = [self.filteredPhone objectAtIndex:indexPath.row];
    
    return item.isLeaf;
}

- (BOOL)tableView:(UITableView *)tableView
 canPerformAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
    performAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    PhoneItem *item = [self.filteredPhone objectAtIndex:indexPath.row];
    
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
