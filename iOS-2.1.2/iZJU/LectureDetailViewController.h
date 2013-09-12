//
//  LectureDetailViewController.h
//  iZJU
//
//  Created by ricky on 12-11-8.
//
//

#import <UIKit/UIKit.h>
#import "ZJUDataRequest.h"
#import "ZJUDataServer.h"
#import "ZJUActivityRequest.h"
#import "PostView.h"

@interface LectureDetailViewController : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
ZJUDateRequestDelegate,
PostViewDelegate>
{
    ZJUActivityDetailItem           * detailItem;
    ZJUActivityDetailRequest        * _request;
    
    UIBarButtonItem                 * postItem;
    PostView                        * postView;
}

@property(strong,nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSString *detailTitle;
@property (strong, nonatomic) IBOutlet UILabel *detailTitleLabel;
@end
