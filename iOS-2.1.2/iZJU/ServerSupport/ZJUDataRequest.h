//
//  ZJUDataRequest.h
//  iZJU
//
//  Created by sheng tan on 12-10-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZJUDataRequest;

@protocol ZJUDateRequestDelegate <NSObject>
@optional
- (void)requestDidRecievedResponse:(ZJUDataRequest*)request
                      withResponse:(NSURLResponse*)response;
- (void)requestDidFinished:(ZJUDataRequest*)request withData:(id)data;
- (void)requestDidFailed:(ZJUDataRequest*)request withError:(NSError*)error;

@end

@interface ZJUDataRequest : NSObject

+ (id)dataRequest;

- (NSString*)host;
- (NSString*)version;
- (void)requestHook:(NSMutableURLRequest*)request;
- (NSURL*)url;
- (id)handler:(id)data error:(NSError**)outError;

@end
