//
//  LectureViewController.h
//  iZJU
//
//  Created by 爱机 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJUDataServer.h"
#import "ZJUActivityRequest.h"

@interface Lecture : UIViewController
<UITableViewDelegate,
UITableViewDataSource,
ZJUDateRequestDelegate>
{
    NSArray             * _activityItems;
    
    ZJUActivityRequest  * _request;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
