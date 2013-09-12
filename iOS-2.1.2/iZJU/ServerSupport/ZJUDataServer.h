//
//  ZJUDataServer.h
//  iZJU
//
//  Created by sheng tan on 12-10-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZJUDateRequestDelegate;

@class ZJUDataRequest;

@interface ZJUDataServer : NSObject
<NSURLConnectionDataDelegate>
{
    NSMutableDictionary             * requestsMap;
    NSMutableArray                  * requestConnections;
}

+ (id)sharedServer;

- (void)executeRequest:(ZJUDataRequest*)request 
              delegate:(id<ZJUDateRequestDelegate>)delegate;
- (void)cancelRequest:(ZJUDataRequest*)request;

@end
