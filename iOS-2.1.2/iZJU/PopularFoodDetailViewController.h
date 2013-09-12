//
//  PopularFoodDetailViewController.h
//  iZJU
//
//  Created by sheng tan on 12-10-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopularFoodDetailViewController : UITableViewController <UIActionSheetDelegate>

/*
 detailInfo:
    Telephone,
    Address,
    Average,
    Recommend,
    Discount,
    Scale,
    Userinfo
 */
@property (nonatomic, strong) NSDictionary *detailInfo;

@end
