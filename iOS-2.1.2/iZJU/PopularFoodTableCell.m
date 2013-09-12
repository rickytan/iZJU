//
//  PopularFoodTableCell.m
//  iZJU
//
//  Created by sheng tan on 12-10-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PopularFoodTableCell.h"

@implementation PopularFoodTableCell
@synthesize restaurantTel, restaurantAddr, restaurantName, restaurantCategory, userInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = self.contentView.bounds.size.width;
    
    CGRect f1 = self.restaurantTel.frame;
    CGRect f2 = self.userInfo.frame;
    
    CGSize fit = [self.restaurantTel sizeThatFits:CGSizeZero];
    f1.size.width = fit.width;
    self.restaurantTel.frame = f1;
    
    fit = [self.userInfo sizeThatFits:CGSizeZero];
    if (CGRectGetMaxX(f1) > CGRectGetMaxX(f2) - fit.width) {
        fit.width = CGRectGetMaxX(f1) - CGRectGetMaxX(f2);
    }
    f2.origin.x = width - fit.width;
    f2.size.width = fit.width;
    self.userInfo.frame = f2;
}

#pragma mark - Methods

- (void)setCellInfoWithName:(NSString *)name 
                        tel:(NSString *)tel
                       addr:(NSString *)addr 
                   category:(NSString *)category 
                      other:(NSString *)userinfo
{
    self.restaurantName.text = name;
    self.restaurantTel.text = tel;
    self.restaurantAddr.text = addr;
    self.restaurantCategory.text = category;
    self.userInfo.text = userinfo;
}
@end
