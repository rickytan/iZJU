//
//  CareerDetailViewController.h
//  iZJU
//
//  Created by ricky on 12-11-10.
//
//

#import <UIKit/UIKit.h>
#import "ZJUCareerRequest.h"
#import "ZJUDataServer.h"

@interface CareerDetailViewController : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
ZJUDateRequestDelegate
>
{
    ZJUCareerDetailItem           * detailItem;
    ZJUCareerDetailRequest        * _request;
}

@property(strong,nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSString *detailTitle;
@property (strong, nonatomic) IBOutlet UILabel *detailTitleLabel;
@end
