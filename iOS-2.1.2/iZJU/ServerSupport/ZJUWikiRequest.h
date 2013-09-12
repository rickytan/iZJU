//
//  ZJUWikiRequest.h
//  iZJU
//
//  Created by ricky on 12-11-10.
//
//

#import "ZJUDataRequest.h"

@interface ZJUWikiItem : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;

@end

@interface ZJUWikiRequest : ZJUDataRequest

@end
