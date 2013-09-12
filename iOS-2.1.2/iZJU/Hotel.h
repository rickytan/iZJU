//
//  Hotel.h
//  iZJU
//
//  Created by 爱机 on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Hotel : UIViewController
<UITableViewDelegate,
UITableViewDataSource>

@property(strong,nonatomic) IBOutlet UITableView *tableView;

@end
