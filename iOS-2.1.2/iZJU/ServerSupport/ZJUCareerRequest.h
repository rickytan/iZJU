//
//  ZJUCareerRequest.h
//  iZJU
//
//  Created by ricky on 12-11-10.
//
//

#import "ZJUDataRequest.h"

@interface ZJUCareerListItem : NSObject
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *place;

@end

@interface ZJUCareerDetailItem : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *details;

@end

@interface ZJUCareerRequest : ZJUDataRequest

@end

@interface ZJUCareerDetailRequest : ZJUDataRequest
@property (nonatomic, strong) NSString *ID;
@end