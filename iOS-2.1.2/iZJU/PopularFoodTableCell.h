//
//  PopularFoodTableCell.h
//  iZJU
//
//  Created by sheng tan on 12-10-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopularFoodTableCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *restaurantName;
@property (nonatomic, strong) IBOutlet UILabel *restaurantTel;
@property (nonatomic, strong) IBOutlet UILabel *restaurantAddr;
@property (nonatomic, strong) IBOutlet UILabel *restaurantCategory;
@property (nonatomic, strong) IBOutlet UILabel *userInfo;

- (void)setCellInfoWithName:(NSString*)name
                        tel:(NSString*)tel 
                       addr:(NSString*)addr
                   category:(NSString*)category
                      other:(NSString*)userinfo;
@end
