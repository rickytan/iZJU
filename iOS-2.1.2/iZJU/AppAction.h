//
//  AppAction.h
//  iZJU
//
//  Created by ricky on 12-11-8.
//
//

#import <Foundation/Foundation.h>

@protocol AppAction <NSObject>
@required
- (void)launchWithController:(UIViewController*)controller;

@end
