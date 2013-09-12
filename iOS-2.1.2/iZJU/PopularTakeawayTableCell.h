//
//  PopularTakeawayTableCell.h
//  iZJU
//
//  Created by sheng tan on 12-10-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

@class PopularTakeawayTableCell;

@protocol PopularTakeawayCellDelegate <NSObject>

- (void)PopularTakeawayCellCall:(PopularTakeawayTableCell*)cell;

@end

@interface PopularTakeawayTableCell : UITableViewCell

@property (nonatomic, assign) IBOutlet id<PopularTakeawayCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel *restaurantName;
@property (nonatomic, strong) IBOutlet UILabel *restaurantTel;
@property (nonatomic, strong) IBOutlet MarqueeLabel *deliveryInfo;
@property (nonatomic, strong) IBOutlet UILabel *userInfo;

- (IBAction)callButtonPressed:(id)sender;
- (void)setCellInfoWithName:(NSString*)name
                        tel:(NSString*)tel
                   delivery:(NSString*)delivery
                      other:(NSString*)userinfo;

@end
