//
//  ZJUPopularTakeawayRequest.h
//  iZJU
//
//  Created by ricky on 12-10-14.
//
//

#import "ZJUDataRequest.h"

@interface ZJUPopularTakeawayItem : NSObject
@property (nonatomic, strong) NSString *shopName;
@property (nonatomic, strong) NSString *mobileNum;
@property (nonatomic, strong) NSString *phoneNum;
@property (nonatomic, strong) NSString *remark;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSArray *dishes;
@end

@interface ZJUPopularTakeawayDish : NSObject
@property (nonatomic, strong) NSString *dishName;
@property (nonatomic, strong) NSString *dishPrice;
@end

@interface ZJUPopularTakeawayRequest : ZJUDataRequest

@end
