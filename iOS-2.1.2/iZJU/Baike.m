//
//  Baike.m
//  iZJU
//
//  Created by 爱机 on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "Baike.h"
#import "ZJUWikiRequest.h"
#import "SVProgressHUD.h"
#import "BaikeDetailViewController.h"

@interface Baike ()
- (void)randomShow;
- (NSArray*)randomPick;
- (void)shakeNotification:(NSNotification*)notification;
@end

@implementation Baike
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"浙大百科";
        
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"shake"
                                                         ofType:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
        
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
    AudioServicesRemoveSystemSoundCompletion(soundID);
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"commonbg.jpg"]];

    
    UIBarButtonItem *randomShow = [[UIBarButtonItem alloc] initWithTitle:@"随机显示"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(randomShow)];
    self.navigationItem.rightBarButtonItem = randomShow;
    CGFloat h = self.searchDisplayController.searchBar.bounds.size.height;
    self.tableView.contentOffset = CGPointMake(0, h);
    
    _request = [ZJUWikiRequest dataRequest];
    
    [[ZJUDataServer sharedServer] executeRequest:_request
                                        delegate:self];
    [SVProgressHUD showWithStatus:@"加载中..."];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shakeNotification:)
                                                 name:UIDeviceDidShakeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[ZJUDataServer sharedServer] cancelRequest:_request];
    [SVProgressHUD dismiss];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TableView

-(void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        BaikeDetailViewController *detail = [[BaikeDetailViewController alloc] init];
        ZJUWikiItem *item = [itemsToShow objectAtIndex:indexPath.row];
        detail.wikiTitle = item.title;
        detail.wikiDetail = item.detail;
        [self.navigationController pushViewController:detail
                                             animated:YES];
    }
    else {
        BaikeDetailViewController *detail = [[BaikeDetailViewController alloc] init];
        ZJUWikiItem *item = [filteredWikiItems objectAtIndex:indexPath.row];
        detail.wikiTitle = item.title;
        detail.wikiDetail = item.detail;
        [self.navigationController pushViewController:detail
                                             animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView == tableView) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
        
        ZJUWikiItem *item = [itemsToShow objectAtIndex:indexPath.row];
        cell.textLabel.text = item.title;
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"SearchResultCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
        }
        ZJUWikiItem *item = [filteredWikiItems objectAtIndex:indexPath.row];
        cell.textLabel.text = item.title;
        return cell;
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView
numberOfRowsInSection:(NSInteger)section
{
    if (self.tableView == tableView)
        return itemsToShow.count;
    else
        return filteredWikiItems.count;
}


#pragma mark - Actions

- (void)shakeNotification:(NSNotification *)notification
{
    if (self.searchDisplayController.isActive)
        return;
    
    AudioServicesPlayAlertSound(soundID);
    [self randomShow];
}

- (void)randomShow
{
    itemsToShow = [self randomPick];
    [self.tableView reloadData];
}

- (NSArray*)randomPick
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:20];
    srand(time(NULL));
    while (arr.count < 20) {
        int index = rand() % wikiItems.count;
        id item = [wikiItems objectAtIndex:index];
        if (![arr containsObject:item]) {
            [arr addObject:item];
        }
    }
    
    return [NSArray arrayWithArray:arr];
}

#pragma mark - UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText
{
    if (searchText && ![searchText isEqualToString:@""]) {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"title contains[c] %@",searchText];
        filteredWikiItems = [wikiItems filteredArrayUsingPredicate:filter];
    }
}

#pragma mark - ZJUDataRequest Delegate

- (void)requestDidFinished:(ZJUDataRequest *)request
                  withData:(id)data
{
    _request = nil;
    
    wikiItems = data;
    
    [self randomShow];
    [SVProgressHUD dismiss];
}

- (void)requestDidFailed:(ZJUDataRequest *)request
               withError:(NSError *)error
{
    _request = nil;
    
    NSLog(@"%@",error);
    [SVProgressHUD showErrorWithStatus:@"矮油，貌似失败了...再试试啦"];
}


@end
