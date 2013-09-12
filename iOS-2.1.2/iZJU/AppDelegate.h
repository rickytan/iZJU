//
//  AppDelegate.h
//  iZJU
//
//  Created by 爱机 on 12-8-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "UserGuideView.h"

@class ViewController;
@class Reachability;

@interface AppDelegate : UIResponder
<UIApplicationDelegate,
UserGuideViewDelegate,
UIAlertViewDelegate>
{
    Reachability                * reachability;
    NSString                    * updateURL;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
