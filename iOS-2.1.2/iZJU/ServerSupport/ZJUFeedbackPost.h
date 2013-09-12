//
//  ZJUFeedbackPost.h
//  iZJU
//
//  Created by ricky on 12-11-10.
//
//

#import "ZJUDataRequest.h"

@interface ZJUFeedbackPost : ZJUDataRequest
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *message;

@end
