//
//  Outside.h
//  iZJU
//
//  Created by 爱机 on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJUOutsideRequest.h"
#import "ZJUDataServer.h"

@interface Outside : UIViewController
<UITableViewDataSource,
ZJUDateRequestDelegate,
UITableViewDelegate>
{
    NSArray                 * _outsideActivities;
    
    ZJUOutsideRequest       * _request;
}

@property(strong,nonatomic) IBOutlet UITableView *tableView;


@end
