//
//  AppDelegate.m
//  iZJU
//
//  Created by 爱机 on 12-8-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "ViewController.h"
#import "SHKConfiguration.h"
#import "DefaultSHKConfigurator.h"
#import "BaiduMobStat.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
//#import "APService.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)initUIStyle
{
    if (IS_IOS_5) {
        
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"outsidenavbar.png"]
                                           forBarMetrics:UIBarMetricsDefault];
        //[[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
        //[[UIBarButtonItem appearance] setTintColor:DEFAULT_COLOR_SCHEME];
        //        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"back_btn.png"]
        //                                                          forState:UIControlStateNormal
        //                                                        barMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setTintColor:DEFAULT_COLOR_SCHEME];
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:[[UIImage imageNamed:@"backitem.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 6)]
                                                                                                      forState:UIControlStateNormal
                                                                                                    barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:[[UIImage imageNamed:@"baritem.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)]
                                                                                            forState:UIControlStateNormal
                                                                                          barMetrics:UIBarMetricsDefault];
        
        [[UISegmentedControl appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:[[UIImage imageNamed:@"baritem.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)]
                                                                                               forState:UIControlStateNormal
                                                                                             barMetrics:UIBarMetricsDefault];
        //[[UIToolbar appearance] setTintColor:DEFAULT_COLOR_SCHEME];
        //[[UIBarButtonItem appearanceWhenContainedIn:UINavigationBar.class, nil] setTintColor:DEFAULT_COLOR_SCHEME];
        
    }
}

- (void)initBaidu
{
    BaiduMobStat *stat = [BaiduMobStat defaultStat];
#error Use your Own AppId on http://mtj.baidu.com/
    //[stat startWithAppId:@""];
}

- (void)initParse
{
#error Use your Own Key on https://parse.com !
    //[Parse setApplicationId:@""
    //              clientKey:@""];
    
    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];
    
    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    
    [PFACL setDefaultACL:defaultACL
withAccessForCurrentUser:YES];
    
    [[PFInstallation currentInstallation] saveEventually];
}

- (BOOL)isFirstLaunch
{
    BOOL rtnval = NO;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *version = [userDefault stringForKey:@"LastLaunchVersion"];
    
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *currVersion = [appInfo valueForKey:@"CFBundleVersion"];
    
    if (!version || [currVersion compare:version
                                 options:NSNumericSearch] == NSOrderedDescending) {
        rtnval = YES;
        [userDefault setValue:currVersion
                       forKey:@"LastLaunchVersion"];
        [userDefault synchronize];
    }
    return rtnval;
}

- (void)checkForUpdate
{
    NSURL *update = [NSURL URLWithString:@"http://www.izju.org/ios_update.txt"];
    NSURLRequest *request = [NSURLRequest requestWithURL:update];
    
    void(^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *r, NSData *d, NSError *e) {
        if (e)
            return;
        NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
        NSString *currVersion = [appInfo valueForKey:@"CFBundleVersion"];
        id json = [NSJSONSerialization JSONObjectWithData:d
                                                  options:NSJSONReadingAllowFragments
                                                    error:NULL];
        if (json) {
            NSString *newVersion = [json valueForKey:@"version"];
            NSString *notifiedUpdateVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"NotifiedUpdateVersion"];
            if ([newVersion isEqualToString:notifiedUpdateVersion])
                return;
            
            if ([newVersion compare:currVersion
                            options:NSNumericSearch] == NSOrderedDescending) {
                
                [[NSUserDefaults standardUserDefaults] setValue:newVersion
                                                         forKey:@"NotifiedUpdateVersion"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                updateURL = [json valueForKey:@"update_url"];
                NSNumber *num = [json objectForKey:@"update_type"];
                if (num && num.intValue > 0) {
                    [[[UIAlertView alloc] initWithTitle:@"有新版本了！"
                                                message:[json valueForKey:@"update_info"]
                                               delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"更新", nil] show];
                }
                else {
                    [[[UIAlertView alloc] initWithTitle:@"有新版本了！"
                                                message:[json valueForKey:@"update_info"]
                                               delegate:self
                                      cancelButtonTitle:@"知道了"
                                      otherButtonTitles:@"去看看", nil] show];
                }
            }
        }
    };
    
    if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus == ReachableViaWWAN) {
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:handler];
    }
}

- (void)showUserGuideWithRemovingView:(UIView*)viewToRemove
{
    UserGuideView *guide = [[UserGuideView alloc] initWithImages:
                            @[@"guide0.png",@"guide1.png"]];
    guide.delegate = self;
    
    [UIView transitionFromView:viewToRemove
                        toView:guide
                      duration:1.0
                       options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionTransitionCurlUp
                    completion:^(BOOL finished) {
                        
                    }];
}

- (void)UserGuideDidFinish:(UserGuideView *)guideview
{
    UIApplication *application = [UIApplication sharedApplication];
    [application setStatusBarHidden:NO
                      withAnimation:UIStatusBarAnimationSlide];
    
    CGRect f = self.window.bounds;
    f.origin.y = application.statusBarFrame.size.height;
    f.size.height -= application.statusBarFrame.size.height;
    self.window.rootViewController.view.frame = f;
    
    self.window.rootViewController.view.transform = CGAffineTransformMakeScale(0.6, 0.6);
    self.window.rootViewController.view.alpha = 1.0f;
    
    [UIView animateWithDuration:1.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         guideview.alpha = 0.0f;
                         self.window.rootViewController.view.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         [guideview removeFromSuperview];
                     }];
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initBaidu];
    [self initParse];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:self.window];
    hud.userInteractionEnabled = NO;
    [self.window addSubview:hud];
    
    [self initUIStyle];
    
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController"
                                                           bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    navController.navigationBarHidden = YES;
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    
    if ([self isFirstLaunch] && NO) {
        UIImage *image = [UIImage imageNamed:@"Default.png"];
        
        __block UIImageView *splashImage = [[UIImageView alloc] initWithFrame:self.window.bounds];
        splashImage.image = image;
        splashImage.contentMode = UIViewContentModeScaleToFill;
        [self.window addSubview:splashImage];
        
        image = [UIImage imageNamed:@"wearelate.jpg"];
        __block UIImageView *wearelate = [[UIImageView alloc] initWithFrame:self.window.bounds];
        wearelate.image = image;
        wearelate.contentMode = UIViewContentModeScaleToFill;
        wearelate.alpha = 0.0f;
        [self.window addSubview:wearelate];
        
        self.window.rootViewController.view.alpha = 0.0f;
        
        [UIView animateWithDuration:0.6
                         animations:^{
                             splashImage.alpha = 0.0f;
                             wearelate.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             [splashImage removeFromSuperview];
                             
                             [self performSelector:@selector(showUserGuideWithRemovingView:)
                                        withObject:wearelate
                                        afterDelay:3.0f];
                         }];
    }
    else {
        [application setStatusBarHidden:NO
                          withAnimation:UIStatusBarAnimationSlide];
        CGRect f = self.window.bounds;
        f.origin.y = application.statusBarFrame.size.height;
        f.size.height -= application.statusBarFrame.size.height;
        self.window.rootViewController.view.frame = f;
        
        UIImage *image = [UIImage imageNamed:(IS_IPHONE_5)?@"Default-568h.png":@"Default.png"];
        
        __block UIImageView *splashImage = [[UIImageView alloc] initWithFrame:self.window.bounds];
        splashImage.image = image;
        splashImage.contentMode = UIViewContentModeScaleToFill;
        [self.window addSubview:splashImage];
        
        [UIView animateWithDuration:0.6
                              delay:0.0
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             splashImage.alpha = 0.3;
                             splashImage.transform = CGAffineTransformMakeTranslation(0, splashImage.bounds.size.height);
                         }
                         completion:^(BOOL finished) {
                             [splashImage removeFromSuperview];
                             splashImage = nil;
                         }];
    }
    
    
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeSound];
    
    if (launchOptions) {
        NSDictionary* pushNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (pushNotificationKey) {
            
            [[BaiduMobStat defaultStat] logEvent:@"push_received"
                                      eventLabel:@"关闭状态下收到推送"];
            
            NSNumber *appid = [pushNotificationKey objectForKey:@"appid"];
            if (appid) {
                [self.viewController launchApplicationWithIndex:[appid intValue]];
            }
        }
    }
    //    [APService registerForRemoteNotificationTypes:
    //     UIRemoteNotificationTypeAlert|
    //     UIRemoteNotificationTypeBadge|
    //     UIRemoteNotificationTypeSound];
    //    [APService setupWithOption:launchOptions];
    
    DefaultSHKConfigurator *configurator = [[DefaultSHKConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    [self performSelector:@selector(checkForUpdate)
               withObject:nil
               afterDelay:3.0];
    
    [self.window bringSubviewToFront:hud];
    
    return YES;
}

- (void)networkHandler:(NSNotification*)notication
{
    switch (reachability.currentReachabilityStatus) {
        case ReachableViaWiFi:
            
            break;
        case ReachableViaWWAN:
            
            break;
        case NotReachable:
            [[[UIAlertView alloc] initWithTitle:@"小提示"
                                        message:@"在没有网络的情况下，某些功能无法正常使用"
                                       delegate:nil
                              cancelButtonTitle:@"知道了"
                              otherButtonTitles:nil] show];
            break;
        default:
            break;
    }
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
    //[APService handleRemoteNotification:userInfo];
    
    [[BaiduMobStat defaultStat] logEvent:@"push_received"
                              eventLabel:@"启动状态下收到推送"];
    
    if (application.applicationState == UIApplicationStateInactive) {
        NSNumber *appid = [userInfo objectForKey:@"appid"];
        if (appid) {
            [self.viewController launchApplicationWithIndex:[appid intValue]];
        }
    }
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [PFPush storeDeviceToken:deviceToken];
#ifdef DEBUG
    [PFPush subscribeToChannelInBackground:@"Debug"
                                    target:self
                                  selector:@selector(subscribeFinished:error:)];
#else
    [PFPush subscribeToChannelInBackground:@"AppStore"
                                    target:self
                                  selector:@selector(subscribeFinished:error:)];
#endif
    
    //[APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
    PFInstallation *install = [PFInstallation currentInstallation];
    if (install.badge > 0) {
        install.badge = 0;
        [install saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [reachability stopNotifier];
}

#pragma mark - Error Handler

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error
{
    if ([result boolValue]) {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
        [[PFInstallation currentInstallation] saveEventually];
    } else {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
}

#pragma mark - UIAlertView Delegate

// 去看看新版本
- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateURL]];
}

@end
