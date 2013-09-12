//
//  PostViewController.h
//  iZJU
//
//  Created by ricky on 12-11-29.
//
//

#import <UIKit/UIKit.h>
#import "PostCell.h"
#import <Parse/Parse.h>
#import "PostView.h"
#import "EGORefreshTableHeaderView.h"

@interface PostViewController : UIViewController
<UITableViewDataSource,
PostCellDelegate,
PostViewDelegate,
EGORefreshTableHeaderDelegate,
UITableViewDelegate>
{
    IBOutlet UITableView            * _tableView;
    IBOutlet UITableViewCell        * _loadMoreCell;
    PostCell                        * _cellForHeight;
    PostView                        * postView;
    EGORefreshTableHeaderView       * _refreshView;
    
    
    PFQuery                         * _query;
    NSDate                          * _firstItemCreatedDate;
    NSDate                          * _lastItemCreatedDate;
    BOOL                              _loading;
    BOOL                              _shouldShowLoadMore;
    
    NSMutableArray                  * _items;
    NSMutableArray                  * _hotItems;

    NSString                        * _referenceText;
    
    NSCache                         * _cellCache;
}

@property (nonatomic, readonly) NSMutableArray *items;
@property (nonatomic, readonly) NSMutableArray *hotItems;
@property (nonatomic, getter = isLoading, readonly) BOOL loading;
@property (nonatomic, strong) NSString *commentType;
@property (nonatomic, strong) NSString *articleId;

- (IBAction)onLoadMore:(id)sender;

@end
