//
//  ZJUOutsideRequest.h
//  iZJU
//
//  Created by ricky on 12-11-8.
//
//

#import "ZJUDataRequest.h"

@interface ZJUOutsideListItem : NSObject <NSCoding>
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *title;

@end

@interface ZJUOutsideRequest : ZJUDataRequest

@end

@interface ZJUOutsideDetailItem : NSObject <NSCoding>
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *details;

@end

@interface ZJUOutsideDetailRequest : ZJUDataRequest
@property (nonatomic, assign) NSString *ID;

@end
