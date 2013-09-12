    //
    //  ZJUDataServer.m
    //  iZJU
    //
    //  Created by sheng tan on 12-10-10.
    //  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
    //

#import "ZJUDataServer.h"
#import "ZJUDataRequest.h"
#import "ZJUSchoolBusDataRequest.h"

static ZJUDataServer * theServerInstance = nil;

@implementation ZJUDataServer

+ (id)sharedServer
{
    @synchronized(self) {
        if (!theServerInstance) {
            theServerInstance = [[ZJUDataServer alloc] init];
        }
        return theServerInstance;
    }
    return nil;
}

- (void)dealloc
{
    theServerInstance = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        requestsMap = [[NSMutableDictionary alloc] initWithCapacity:13];
        requestConnections = [[NSMutableArray alloc] initWithCapacity:13];
    }
    return self;
}

- (void)executeRequest:(ZJUDataRequest *)request
              delegate:(id<ZJUDateRequestDelegate>)delegate
{
    if ([requestsMap objectForKey:request.url])
        return;
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:request.url];

    [request requestHook:urlRequest];

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:urlRequest
                                                                delegate:self];

    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          request,@"Request",
                          connection,@"Connection",
                          delegate,@"Delegate",
                          [NSMutableData data],@"Data", nil];
    
    [requestsMap setObject:info
                    forKey:request.url];
    
    [connection start];
        //    [NSURLConnection sendAsynchronousRequest:urlRequest
        //                                       queue:[NSOperationQueue currentQueue]
        //                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        //                               
        //                           }];
}

- (void)cancelRequest:(ZJUDataRequest *)request
{
    if (!request)
        return;
    
    NSDictionary *info = [requestsMap objectForKey:request.url];
    NSURLConnection *conn = [info objectForKey:@"Connection"];
    [conn cancel];
    
    [requestsMap removeObjectForKey:request.url];
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection 
didReceiveResponse:(NSURLResponse *)response
{
    NSDictionary *info = [requestsMap objectForKey:connection.currentRequest.URL];
    id<ZJUDateRequestDelegate> delegate = [info objectForKey:@"Delegate"];
    ZJUDataRequest *request = [info objectForKey:@"Request"];
    if ([delegate respondsToSelector:@selector(requestDidRecievedResponse:withResponse:)])
        [delegate requestDidRecievedResponse:request
                                withResponse:response];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    NSDictionary *info = [requestsMap objectForKey:connection.currentRequest.URL];
    NSMutableData *recievedData = [info objectForKey:@"Data"];
    [recievedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *info = [requestsMap objectForKey:connection.currentRequest.URL];
    id<ZJUDateRequestDelegate> delegate = [info objectForKey:@"Delegate"];
    ZJUDataRequest *request = [info objectForKey:@"Request"];
    NSData *data = [info objectForKey:@"Data"];
    __autoreleasing NSError *error = nil;
    id obj = [request handler:data error:&error];
    if (error) {
        if ([delegate respondsToSelector:@selector(requestDidFailed:withError:)])
            [delegate requestDidFailed:request withError:error];
    }
    else {
        if ([delegate respondsToSelector:@selector(requestDidFinished:withData:)])
            [delegate requestDidFinished:request withData:obj];
    }
    
    [requestsMap removeObjectForKey:request.url];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSDictionary *info = [requestsMap objectForKey:connection.currentRequest.URL];
    id<ZJUDateRequestDelegate> delegate = [info objectForKey:@"Delegate"];
    ZJUDataRequest *request = [info objectForKey:@"Request"];
    if ([delegate respondsToSelector:@selector(requestDidFailed:withError:)])
        [delegate requestDidFailed:request withError:error];
    
    [requestsMap removeObjectForKey:connection.currentRequest.URL];
}

@end
