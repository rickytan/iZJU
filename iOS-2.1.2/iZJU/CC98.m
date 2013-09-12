//
//  CC98.m
//  iZJU
//
//  Created by ricky on 13-1-11.
//
//

#import "CC98.h"
#import "CC98Cell.h"
#import "SVProgressHUD.h"

@interface CC98 ()
@property (nonatomic, strong) MWFeedParser *feedParser;
- (void)onRefresh:(id)sender;
@end

@implementation CC98
@synthesize tableView = _tableView;
@synthesize top10Items = _top10Items;
@synthesize feedParser = _feedParser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"98十大";
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
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                             target:self
                                                                             action:@selector(onRefresh:)];
    self.navigationItem.rightBarButtonItem = refresh;
    
    [self onRefresh:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)onRefresh:(id)sender
{
    if (self.feedParser.isParsing)
        return;
    
    if ([self.feedParser parse])
        [SVProgressHUD showWithStatus:@"十大又发生了什么呢？"];
}

#pragma mark - getter&setter

- (NSMutableArray*)top10Items
{
    if (!_top10Items) {
        _top10Items = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return _top10Items;
}

- (MWFeedParser*)feedParser
{
    if (!_feedParser) {
        NSURL *url = [NSURL URLWithString:@"http://www.cc98.org/rss.asp"];
        _feedParser = [[MWFeedParser alloc] initWithFeedURL:url];
        _feedParser.delegate = self;
        _feedParser.connectionType = ConnectionTypeAsynchronously;
        _feedParser.feedParseType = ParseTypeItemsOnly;
    }
    return _feedParser;
}

#pragma mark - TableView Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.top10Items.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CC98Cell";
    CC98Cell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CC98Cell"
                                              owner:self
                                            options:nil] lastObject];
    }
    [cell setFeedItem:[self.top10Items objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - MWFeedParser Delegate

- (void)feedParserDidStart:(MWFeedParser *)parser
{
    [self.top10Items removeAllObjects];
}

- (void)feedParser:(MWFeedParser *)parser
  didParseFeedItem:(MWFeedItem *)item
{
    [self.top10Items addObject:item];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser
{
    [SVProgressHUD showSuccessWithStatus:@"更新完毕"];
    [self.tableView reloadData];
}

- (void)feedParser:(MWFeedParser *)parser
  didFailWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:error.description];
}

@end
