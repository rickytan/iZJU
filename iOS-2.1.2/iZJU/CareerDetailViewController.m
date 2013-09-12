//
//  CareerDetailViewController.m
//  iZJU
//
//  Created by ricky on 12-11-10.
//
//

#import "CareerDetailViewController.h"
#import "SVProgressHUD.h"
#import "CareerDetailTableCell.h"

@interface CareerDetailViewController ()

@end

@implementation CareerDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"详情";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.detailTitleLabel.text = self.detailTitle;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (detailItem)
        return;
    
    _request = [ZJUCareerDetailRequest dataRequest];
    _request.ID = self.ID;
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

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return detailItem.details.count;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    NSString *text = [[detailItem.details objectAtIndex:row] valueForKey:@"value"];
    CGSize size = CGSizeMake(224, MAXFLOAT);
    UIFont *font = [UIFont systemFontOfSize:12];
    size = [text sizeWithFont:font
            constrainedToSize:size
                lineBreakMode:UILineBreakModeWordWrap];
    return MAX(size.height + 22, 44);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DetailCell";
    CareerDetailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CareerDetailTableCell"
                                              owner:self
                                            options:nil] objectAtIndex:0];
    }
    
    cell.content.text = [[detailItem.details objectAtIndex:indexPath.row] valueForKey:@"value"];
    cell.title.text = [[[detailItem.details objectAtIndex:indexPath.row] valueForKey:@"key"] stringByAppendingString:@"："];
    // Configure the cell...
    
    return cell;
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
