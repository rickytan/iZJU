//
//  PostViewController.m
//  iZJU
//
//  Created by ricky on 12-11-29.
//
//

#import "PostViewController.h"
#import <Parse/Parse.h>
#import "PostView.h"
#import "MBProgressHUD.h"
#import "SVProgressHUD.h"
#import "Post.h"

@interface PostViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL loading;
- (void)loadRefreshData;
- (void)loadPrependingData;
- (void)prependNewData:(NSArray*)data;
- (void)loadAppendingData;
- (void)appendNewData:(NSArray*)data;
/*
- (PostCell*)prepareCellForIndexPath:(NSIndexPath*)indexPath;
- (void)configureCell:(PostCell*)cell
         forIndexPath:(NSIndexPath*)indexPath;
 */
@end

@implementation PostViewController
@synthesize tableView = _tableView;
@synthesize items = _items;
@synthesize hotItems = _hotItems;
@synthesize commentType = _commentType;
@synthesize loading = _loading;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"所有帖子";
        
        _referenceText = @"";
        _items = [[NSMutableArray alloc] initWithCapacity:10];
        _hotItems = [[NSMutableArray alloc] initWithCapacity:3];
        
        _cellForHeight = [[[NSBundle mainBundle] loadNibNamed:@"PostCell"
                                                        owner:self
                                                      options:nil] objectAtIndex:0];
        
    }
    return self;
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

- (void)dealloc
{
    
    postView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (!_refreshView) {
        _refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -CGRectGetHeight(self.tableView.bounds), CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.tableView.bounds))];
        _refreshView.delegate = self;
    }
    [_refreshView refreshLastUpdatedDate];
    [self.tableView addSubview:_refreshView];
    
    postView = [[PostView alloc] init];
    postView.delegate = self;
    postView.frame = CGRectMake(0, self.view.bounds.size.height - 48,
                                self.view.bounds.size.width, 48);
    [self.view addSubview:postView];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.margin = 10.0f;
    hud.mode = MBProgressHUDModeText;
    hud.userInteractionEnabled = NO;
    [hud setYOffset:-120];
    [self.view addSubview:hud];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.items.count > 0)
        return;
    
    [self loadRefreshData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_query cancel];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter&setter

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    if (_loading == NO) {
        [_refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
}

#pragma mark - Methods

- (void)loadRefreshData
{
    _firstItemCreatedDate = _lastItemCreatedDate = [NSDate date];
    
    _query = [PFQuery queryWithClassName:self.commentType];
    [_query whereKey:@"articleId"
             equalTo:self.articleId];
    [_query orderByDescending:@"createdAt"];
    _query.limit = 25;
    
    self.loading = YES;
    [_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            [SVProgressHUD dismiss];
            if (objects.count > 0) {
                PFObject *lastItem = objects.lastObject;
                _lastItemCreatedDate = lastItem.createdAt;

                if (objects.count == 25) {
                    _shouldShowLoadMore = YES;
                }
                else {
                    _shouldShowLoadMore = NO;
                }

                [self.items removeAllObjects];
                
                for (PFObject *o in objects) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                o, @"item",
                                                [NSNumber numberWithBool:NO], @"upped", nil];
                    [self.items addObject:dic];
                }
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                              withRowAnimation:UITableViewRowAnimationBottom];
                
            }
            else {
                MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view.window];
                hud.mode = MBProgressHUDModeText;
                hud.margin = 8.0f;
                hud.yOffset = 120.0f;
                hud.animationType = MBProgressHUDAnimationFade;
                hud.labelText = @"没有更多了";
                [hud show:YES];
                [hud hide:YES
               afterDelay:1.0];
            }
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"网络不给力啊..."];
        }
        _query = nil;
        self.loading = NO;
    }];
    
    PFQuery *hotQuery = [PFQuery queryWithClassName:self.commentType];
    
    [hotQuery whereKey:@"articleId"
             equalTo:self.articleId];
    [hotQuery whereKey:@"upCount"
           greaterThan:[NSNumber numberWithInt:0]];
    [hotQuery addDescendingOrder:@"upCount"];
    [hotQuery addDescendingOrder:@"createdAt"];
    hotQuery.limit = 3;
    hotQuery.maxCacheAge = 10.0f;
    [hotQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count > 0) {

                [self.hotItems removeAllObjects];
                
                for (PFObject *o in objects) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                o, @"item",
                                                [NSNumber numberWithBool:NO], @"upped", nil];
                    [self.hotItems addObject:dic];
                }
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                              withRowAnimation:UITableViewRowAnimationBottom];
                
            }
        }
    }];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setStatus:@"加载中..."];
}

/**
 * 这是一种刷新的省流量方案，即只加载第一条的时间以前的数据，然后插在前面，但是可能出问题，
 * 因为用户发帖后没有重新加载数据。如果用户每发一帖就重新加载，可以使用此方案。
 */
- (void)loadPrependingData
{
    _query = [PFQuery queryWithClassName:self.commentType];
    [_query whereKey:@"articleId"
             equalTo:self.articleId];
    [_query whereKey:@"createdAt"
         greaterThan:_firstItemCreatedDate];    // 这里的 _firstItemCreatedDate 在用户成功发帖后更新
    [_query orderByDescending:@"createdAt"];
    
    self.loading = YES;
    [_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            [SVProgressHUD dismiss];
            _firstItemCreatedDate = [NSDate date];
            if (objects.count > 0) {
                [self prependNewData:objects];
            }
            else {
                MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view.window];
                hud.mode = MBProgressHUDModeText;
                hud.margin = 8.0f;
                hud.yOffset = 120.0f;
                hud.animationType = MBProgressHUDAnimationFade;
                hud.labelText = @"没有更多了";
                [hud show:YES];
                [hud hide:YES
               afterDelay:1.0];
            }
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"网络不给力啊..."];
        }
        _query = nil;
        self.loading = NO;
    }];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setStatus:@"加载中..."];
}

- (void)prependNewData:(NSArray *)data
{
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:data.count];
    int index = 0;
    for (PFObject *o in data) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    o, @"item",
                                    [NSNumber numberWithBool:NO], @"upped", nil];
        [indexes addObject:[NSIndexPath indexPathForRow:index
                                              inSection:1]];
        [self.items insertObject:dic
                         atIndex:index++];
    }
    
    [self.tableView insertRowsAtIndexPaths:indexes
                          withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)loadAppendingData
{
    _query = [PFQuery queryWithClassName:self.commentType];
    [_query whereKey:@"articleId"
             equalTo:self.articleId];
    [_query whereKey:@"createdAt"
            lessThan:_lastItemCreatedDate];
    [_query orderByDescending:@"createdAt"];
    _query.limit = 25;
    
    self.loading = YES;
    [_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (!error) {
            [SVProgressHUD dismiss];
            if (objects.count > 0) {
                PFObject *lastItem = objects.lastObject;
                _lastItemCreatedDate = lastItem.createdAt;
                [self appendNewData:objects];
            }
            else {
                MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view.window];
                hud.mode = MBProgressHUDModeText;
                hud.margin = 8.0f;
                hud.yOffset = 120.0f;
                hud.animationType = MBProgressHUDAnimationFade;
                hud.labelText = @"没有更多了";
                [hud show:YES];
                [hud hide:YES
               afterDelay:1.0];
            }
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"网络不给力啊..."];
        }
        _query = nil;
        self.loading = NO;
    }];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setStatus:@"加载中..."];
    
}

- (void)appendNewData:(NSArray *)data
{
    BOOL lastState = _shouldShowLoadMore;
    if (data.count == 25) {
        _shouldShowLoadMore = YES;
    }
    else {
        _shouldShowLoadMore = NO;
    }
    if (_shouldShowLoadMore == NO && lastState == YES) {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.items.count
                                                                    inSection:1]]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
    
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:data.count];
    for (PFObject *o in data) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    o, @"item",
                                    [NSNumber numberWithBool:NO], @"upped", nil];
        [indexes addObject:[NSIndexPath indexPathForRow:self.items.count
                                              inSection:1]];
        [self.items addObject:dic];
    }
    
    if (_shouldShowLoadMore == YES && lastState == NO) {
        [indexes addObject:[NSIndexPath indexPathForRow:self.items.count
                                              inSection:1]];
    }
    
    
    [self.tableView insertRowsAtIndexPaths:indexes
                          withRowAnimation:UITableViewRowAnimationLeft];
}

/*
 - (NSString*)formatDate:(NSDate*)date
 {
 NSString *dateStr = @"秒前";
 NSTimeInterval time = -[date timeIntervalSinceNow];
 if (time > 60.0) {
 time /= 60;
 dateStr = @"分钟前";
 if (time > 60.0) {
 time /= 60;
 dateStr = @"小时前";
 if (time > 24.0) {
 time /= 24;
 dateStr = @"天前";
 if (time > 7) {     // 一星期以前的，直接显示时间
 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
 [formatter setDateStyle:NSDateFormatterMediumStyle];
 [formatter setDateFormat:@"MM月dd日"];
 [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
 dateStr = [formatter stringFromDate:date];
 return dateStr;
 }
 }
 }
 }
 dateStr = [NSString stringWithFormat:@"%d%@",(int)time,dateStr];
 return dateStr;
 }
 
 - (PostCell*)prepareCellForIndexPath:(NSIndexPath *)indexPath
 {
 if (!_cellCache)
 {
 _cellCache = [[NSCache alloc] init];
 }
 
 // workaround for iOS 5 bug
 NSString *key = [NSString stringWithFormat:@"%d-%d", indexPath.section, indexPath.row];
 PostCell *cell = [_cellCache objectForKey:key];
 
 if (!cell)
 {
 // reuse does not work for variable height
 //cell = (DTAttributedTextCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
 
 if (!cell)
 {
 cell = [[[NSBundle mainBundle] loadNibNamed:@"PostCell"
 owner:self
 options:nil] objectAtIndex:0];
 }
 
 // cache it
 [_cellCache setObject:cell forKey:key];
 }
 
 [self configureCell:cell forIndexPath:indexPath];
 
 return cell;
 }
 
 - (void)configureCell:(PostCell *)cell
 forIndexPath:(NSIndexPath *)indexPath
 {
 NSDictionary *dic = [self.items objectAtIndex:indexPath.row];
 PFObject *obj = [dic objectForKey:@"item"];
 NSNumber *up = [dic objectForKey:@"upped"];
 [cell setupCell:obj upped:[up boolValue]];
 }
 */

#pragma mark - Actions

- (IBAction)onLoadMore:(id)sender
{
    if (self.isLoading)
        return;
    
    [self loadAppendingData];
}

#pragma mark - PostCell Delegate

- (void)postCellDidPressUp:(PostCell *)cell
{
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    NSDictionary *dic = nil;
    if (index.section == 0)
        dic = [self.hotItems objectAtIndex:index.row];
    else
        dic = [self.items objectAtIndex:index.row];
    
    PFObject *obj = [dic objectForKey:@"item"];
    [obj incrementKey:@"upCount"];
    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSMutableDictionary *dic = [self.items objectAtIndex:index.row];
            [dic setValue:[NSNumber numberWithBool:YES]
                   forKey:@"upped"];
            
            cell.upped = YES;
            [cell increateUpCount];
            
            MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view.window];
            hud.mode = MBProgressHUDModeText;
            hud.margin = 8.0f;
            hud.yOffset = 120.0f;
            hud.animationType = MBProgressHUDAnimationFade;
            hud.labelText = @"顶帖成功！";
            [hud show:YES];
            [hud hide:YES
           afterDelay:1.0f];
        }
    }];
}

- (void)postCellDidPressReply:(PostCell *)cell
{
    _referenceText = [NSString stringWithFormat:@"[%@ 说：]%@",cell.postUser.text,cell.postContent.text];
    [postView.textField becomeFirstResponder];
}

#pragma mark - PostView Delegate

- (void)postViewDidTapStar:(PostView *)postView
{
    
}

- (void)postViewDidTapSend:(PostView *)_postView
{
    if ([NSString isNullOrEmpty:postView.textField.text]) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        [hud setLabelText:@"…说几句吧"];
        [hud show:YES];
        [hud hide:YES
       afterDelay:1.0];
        return;
    }
    else {
        
        Post *aPost = [[Post alloc] init];
        aPost.content = postView.textField.text;
        aPost.articleId = self.articleId;
        aPost.articleType = self.commentType;
        aPost.referenceText = _referenceText;
        [aPost sendWithCompleteBlockHasPostedObject:^(BOOL succeed, PFObject *obj) {
            _referenceText = @"";
            
            MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
            
            if (succeed) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            obj, @"item",
                                            [NSNumber numberWithBool:NO], @"upped", nil];
                _firstItemCreatedDate = obj.createdAt;
                [self.items insertObject:dic
                                 atIndex:0];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0
                                                                            inSection:1]]
                                      withRowAnimation:UITableViewRowAnimationTop];
                
                [hud setLabelText:@"发布成功！"];
                postView.textField.text = nil;
            }
            else
                [hud setLabelText:@"网络错误..."];
            [hud show:YES];
            [hud hide:YES
           afterDelay:1.0];
        }];
        
        [postView resignFirstResponder];
    }
}

#pragma mark - EGORefreshTableHeaderView Delegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self loadRefreshData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return self.isLoading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return self.hotItems.count;
    return self.items.count + (_shouldShowLoadMore?1:0);
}

- (NSString*)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"最多顶帖";
    return @"最近新帖";
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == self.items.count)
        return 44;
    
    NSArray *arr = indexPath.section ? self.items : self.hotItems;
    NSDictionary *dic = [arr objectAtIndex:indexPath.row];
    PFObject *obj = [dic objectForKey:@"item"];
    NSNumber *up = [dic objectForKey:@"upped"];
    
    [_cellForHeight setupCell:obj
                        upped:[up boolValue]];
    
	return [_cellForHeight desiredHeightInTableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PostCell";
    
    if (indexPath.section == 1 && indexPath.row == self.items.count)
        return _loadMoreCell;
    
    PostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PostCell"
                                              owner:self
                                            options:nil] objectAtIndex:0];
    }
    NSArray *arr = indexPath.section ? self.items : self.hotItems;
    NSDictionary *dic = [arr objectAtIndex:indexPath.row];
    PFObject *obj = [dic objectForKey:@"item"];
    NSNumber *up = [dic objectForKey:@"upped"];
    
    [cell setupCell:obj upped:[up boolValue]];
    
    // Configure the cell...
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
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

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostCell *cell = (PostCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell becomeFirstResponder];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [postView resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    [_refreshView egoRefreshScrollViewDidEndDragging:scrollView];
}

@end
