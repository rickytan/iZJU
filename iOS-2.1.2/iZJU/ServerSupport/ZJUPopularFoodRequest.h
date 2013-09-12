//
//  ZJUPopularFoodRequest.h
//  iZJU
//
//  Created by ricky on 12-10-14.
//
//

#import "ZJUDataRequest.h"

@interface ZJUFoodItem : NSObject
@property (nonatomic,strong) NSString *shopName;
@property (nonatomic,strong) NSString *mobileNum;
@property (nonatomic,strong) NSString *phoneNum;
@property (nonatomic,strong) NSString *category;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *discount;
@property (nonatomic,strong) NSString *price;
@property (nonatomic,strong) NSString *scale;
@property (nonatomic,strong) NSString *remark;
@property (nonatomic,strong) NSString *recomand;
@end


@interface ZJUPopularFoodRequest : ZJUDataRequest

@end
