//
//  PopularTakeawayTableCell.m
//  iZJU
//
//  Created by sheng tan on 12-10-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PopularTakeawayTableCell.h"

@implementation PopularTakeawayTableCell
@synthesize delegate = _delegate;
@synthesize restaurantTel, restaurantName, deliveryInfo, userInfo;

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.deliveryInfo.marqueeType = MLLeftRight;
    self.deliveryInfo.textAlignment = UITextAlignmentRight;
    self.deliveryInfo.font = [UIFont systemFontOfSize:13.0f];
    self.deliveryInfo.fadeLength = 8.0f;
}

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

- (void)prepareForReuse
{
    restaurantName.text = nil;
    restaurantTel.text = nil;
    userInfo.text = nil;
    [deliveryInfo resetLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = self.contentView.bounds.size.width;
    
    CGRect r = self.restaurantTel.frame;
    CGSize fit = [self.restaurantTel sizeThatFits:CGSizeZero];
    r.size.width = MIN(fit.width, 220 - r.origin.x);
    self.restaurantTel.frame = r;
    
    r = self.restaurantName.frame;
    fit = [self.restaurantName sizeThatFits:CGSizeZero];
    r.size.width = MIN(fit.width,220 - r.origin.x);
    self.restaurantName.frame = r;
    
    CGRect f2 = self.deliveryInfo.frame;
    fit = [self.deliveryInfo sizeThatFits:CGSizeZero];

    f2.origin.x = MAX(width - fit.width - 2,CGRectGetMaxX(r));
    f2.size.width = width - f2.origin.x;
    self.deliveryInfo.frame = f2;
}

#pragma mark - Acitons

- (IBAction)callButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(PopularTakeawayCellCall:)])
        [self.delegate PopularTakeawayCellCall:self];
}

#pragma mark - Methods

- (void)setCellInfoWithName:(NSString *)name
                        tel:(NSString *)tel
                   delivery:(NSString *)delivery
                      other:(NSString *)userinfo
{
    self.restaurantName.text = name;
    self.restaurantTel.text = tel;
    //self.deliveryInfo.text = delivery;
    self.deliveryInfo.text = delivery;
    self.userInfo.text = userinfo;
}

@end
