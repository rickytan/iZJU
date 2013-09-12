//
//  ActivityDetailViewController.h
//  iZJU
//
//  Created by 爱机 on 12-9-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJUOutsideRequest.h"
#import "ZJUDataServer.h"

@interface ActivityDetail : UIViewController
<UITableViewDelegate,
UITableViewDataSource,
ZJUDateRequestDelegate>
{
    NSArray                     * _detailInfo;
    
    ZJUOutsideDetailRequest     * _request;
}
@property(strong,nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSString *ID;
@property (strong, nonatomic) NSString *detailTitle;
@property (strong, nonatomic) IBOutlet UILabel *detailTitleLabel;
@end
