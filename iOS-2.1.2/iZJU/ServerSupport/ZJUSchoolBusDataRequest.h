//
//  ZJUSchoolBusDataRequest.h
//  iZJU
//
//  Created by sheng tan on 12-10-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ZJUDataRequest.h"

@interface ZJUSchoolBusDataItem : NSObject
@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong) NSString *to;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *place;
@property (nonatomic, strong) NSString *remark;

@end

@interface ZJUSchoolBusDataRequest : ZJUDataRequest


@end
