//
//  ZJUDataRequest.m
//  iZJU
//
//  Created by sheng tan on 12-10-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ZJUDataRequest.h"

@implementation ZJUDataRequest

+ (id)dataRequest
{
#if IS_ARC
    return [[self alloc] init];
#else
    return [[[self alloc] init] autorelease];
#endif
}

- (NSString*)host
{
    return server_host_name;
}

- (NSString*)version
{
    return server_api_version;
}

- (void)requestHook:(NSMutableURLRequest *)request
{
    // Do nothing
}

- (NSURL*)url
{
    NSAssert(NO, @"You have to sub-class this!!!");
    return nil;
}

- (id)handler:(id)data error:(NSError *__autoreleasing *)outError
{
    if (outError)
        *outError = nil;
    return data;    // Sub-class if you have to do sth. with the origin data
}

@end
