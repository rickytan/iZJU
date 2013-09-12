//
//  LectureDetailViewController.m
//  iZJU
//
//  Created by ricky on 12-11-8.
//
//

#import "LectureDetailViewController.h"
#import "LectureDetailTableCell.h"
#import "ZJUActivityRequest.h"
#import "SVProgressHUD.h"
#import "MBProgressHUD.h"
#import "Post.h"
#import "PostViewController.h"
#import "PostView.h"

@interface LectureDetailViewController ()

- (void)getPostCount;

@end

@implementation LectureDetailViewController
@synthesize tableView = _tableView,detailTitleLabel = _detailTitleLabel;
@synthesize ID,detailTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"详情";
        
        postItem = [[UIBarButtonItem alloc] initWithTitle:@"...跟帖"
                                                    style:UIBarButtonItemStyleBordered
                                                   target:self
                                                   action:@selector(onPost:)];
        self.navigationItem.rightBarButtonItem = postItem;
        
    }
    return self;
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass(self.class)
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
    
    self.detailTitleLabel.text = self.detailTitle;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"commonbg.jpg"]]];
    
    postView = [[PostView alloc] init];
    postView.frame = CGRectMake(0, self.view.bounds.size.height - postView.bounds.size.height,
                                postView.bounds.size.width, postView.bounds.size.height);
    postView.delegate = self;
    [self.view addSubview:postView];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.margin = 10.0f;
    hud.mode = MBProgressHUDModeText;
    [hud setYOffset:-120];
    [self.view addSubview:hud];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self performSelector:@selector(getPostCount)
               withObject:nil];

    if (detailItem)
        return;
    
    _request = [ZJUActivityDetailRequest dataRequest];
    _request.activityID = self.ID;
    [[ZJUDataServer sharedServer] executeRequest:_request
                                        delegate:self];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setStatus:@"加载中..."];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[ZJUDataServer sharedServer] cancelRequest:_request];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)onPost:(id)sender
{
    PostViewController *postController = [[PostViewController alloc] init];
    postController.commentType = @"CommentsOfInfo";
    postController.articleId = self.ID;
    [self.navigationController pushViewController:postController
                                         animated:YES];
}

- (void)getPostCount
{
    [Post getPostCountOfType:@"CommentsOfInfo"
                   articleId:self.ID
                   withBlock:^(NSInteger count) {
                       postItem.title = [NSString stringWithFormat:@"%d跟帖",count];
                   }];
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
        aPost.articleId = self.ID;
        aPost.articleType = @"CommentsOfInfo";
        [aPost sendWithCompleteBlock:^(BOOL succeed) {
            [self getPostCount];
            
            MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
            if (succeed) {
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

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = nil;
    switch (indexPath.row) {
        case 0:
            text = detailItem.time;
            break;
        case 1:
            text = detailItem.place;
            break;
        case 2:
            text = detailItem.detail;
            break;
        case 3:
            text = detailItem.zhuban;
            break;
        case 4:
            text = detailItem.contractor;
            break;
        default:
            break;
    }
    if ([NSString isNullOrEmpty:text])
        text = @"";
    CGSize size = CGSizeMake(224, MAXFLOAT);
    UIFont *font = [UIFont systemFontOfSize:12];
    size = [text sizeWithFont:font
            constrainedToSize:size
                lineBreakMode:UILineBreakModeWordWrap];
    return MAX(size.height + 22, 44);
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActivityDetailCell";
    LectureDetailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LectureDetailTableCell"
                                              owner:self
                                            options:nil] objectAtIndex:0];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.title.text = @"时间：";
            cell.content.text = detailItem.time;
            break;
        case 1:
            cell.title.text = @"地点：";
            cell.content.text = detailItem.place;
            break;
        case 2:
            cell.title.text = @"简介：";
            cell.content.text = detailItem.detail;
            break;
        case 3:
            cell.title.text = @"主办：";
            cell.content.text = detailItem.zhuban;
            break;
        case 4:
            cell.title.text = @"承办：";
            cell.content.text = detailItem.contractor;
            break;
        default:
            break;
    }
    // Configure the cell...
    
    return cell;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [postView resignFirstResponder];
}

#pragma mark - ZJUDateRequest Delegate

- (void)requestDidFailed:(ZJUDataRequest *)request
               withError:(NSError *)error
{
    _request = nil;
    detailItem = nil;
    [SVProgressHUD showErrorWithStatus:@"加载失败!"];
}

- (void)requestDidFinished:(ZJUDataRequest *)request
                  withData:(id)data
{
    _request = nil;
    
    detailItem = data;
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
}

@end
