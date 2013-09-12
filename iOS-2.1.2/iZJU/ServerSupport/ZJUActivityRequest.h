//
//  ZJUActivityRequest.h
//  iZJU
//
//  Created by ricky on 12-11-8.
//
//

#import "ZJUDataRequest.h"

@interface ZJUActivityListItem : NSObject
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *place;

@end

@interface ZJUActivityRequest : ZJUDataRequest

@end


@interface ZJUActivityDetailItem : NSObject
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *contractor;
@property (nonatomic, strong) NSString *place;
@property (nonatomic, strong) NSString *zhuban;
@end

@interface ZJUActivityDetailRequest : ZJUDataRequest

@property (nonatomic, assign) NSString *activityID;

@end