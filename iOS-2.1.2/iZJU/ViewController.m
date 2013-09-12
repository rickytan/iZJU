//
//  ViewController.m
//  iZJU
//
//  Created by 爱机 on 12-8-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "AppAction.h"
#import "SVProgressHUD.h"
#import "SHK.h"
#import "SHKConfiguration.h"
#import "SHKActionSheet.h"
#import "BaiduMobStat.h"
#import "AboutViewController.h"

#define ICON_WIDTH  60.0f
#define ICON_HEIGHT 81.0f

#define ICON_MARGIN 15.0f

#define ICON_TAG_OFFSET 100



@interface ViewController ()

- (NSArray*)loadApplications;
- (void)launchApplication:(NSString*)action;

- (void)grow;
@end

@implementation ViewController

@synthesize scroll;
@synthesize pageControl = _pageControl;
@synthesize backButton = _backButton;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *applications = [self loadApplications];
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat offsetX = (width - ICON_WIDTH * 4 - ICON_MARGIN * 3) / 2;
    CGFloat offsetY = 41.0f-(IS_IPHONE_5?11:0);
    CGFloat deltaX = ICON_WIDTH + ICON_MARGIN;
    CGFloat deltaY = ICON_HEIGHT + ((IS_IPHONE_5)?20.0f:38.0f);
    NSInteger numOfIconInPage = (IS_IPHONE_5)?12:8;
    
    int numOfPages = (int)ceilf(1.0 * applications.count / numOfIconInPage);

    iconLayers = [NSMutableArray arrayWithCapacity:applications.count];
    for (int i=0; i < applications.count; ++i) {
        int page = i / numOfIconInPage;
        int pos = i % numOfIconInPage;
        int x = pos % 4;
        int y = pos / 4;
        
        NSDictionary *appInfo = [applications objectAtIndex:i];
        
        Appicon *icon = [[[NSBundle mainBundle] loadNibNamed:@"Appicon"
                                                       owner:self
                                                     options:nil] objectAtIndex:0];
        UIImage *img = [UIImage imageNamed:[appInfo valueForKey:@"AppIcon"]];
        img = img ? img : [UIImage imageNamed:@"appicon_default.png"];
        [icon setImage:img
                 label:[appInfo valueForKey:@"AppName"]];
        icon.frame = CGRectMake(page * width + offsetX + deltaX * x, offsetY + deltaY * y,
                                ICON_WIDTH, ICON_HEIGHT);
        icon.hidden = YES;
        icon.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        icon.action = [appInfo valueForKey:@"AppAction"];
        
        [self.scroll addSubview:icon];
        [iconLayers addObject:icon.layer];
    }
    
    CGRect frame = self.scroll.frame;
    [self.scroll setContentSize:CGSizeMake(frame.size.width*numOfPages, frame.size.height)];
    self.pageControl.numberOfPages = numOfPages;
    self.scroll.bounces = !(numOfPages <= 1);
    
    [self performSelector:@selector(grow)
               withObject:nil
               afterDelay:0.35];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[BaiduMobStat defaultStat] pageviewStartWithName:@"首页"];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[BaiduMobStat defaultStat] pageviewEndWithName:@"首页"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isPageChanging)
        return;
    
    CGPoint offset = self.scroll.contentOffset;
    CGFloat width = self.scroll.frame.size.width;
    CGFloat offsetX = offset.x;
    
    int currentPage = (int)floorf(((offsetX + width / 2.0) / width));
    self.pageControl.currentPage = currentPage;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    isPageChanging = NO;
}

#pragma mark - Private Methods

- (NSArray*)loadApplications
{
#ifdef DEBUG
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Applications"
                                                     ofType:@"plist"];
#else
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Applications"
                                                     ofType:@"plist"];
#endif
    NSArray *apps = [NSArray arrayWithContentsOfFile:path];
    return apps;
}

- (void)launchApplication:(NSString *)action
{
    if (![NSString isNullOrEmpty:action]) {
        Class controllerClass = NSClassFromString(action);
        
        if ([controllerClass isSubclassOfClass:UIViewController.class]) {
            UIViewController *controller = [[controllerClass alloc] init];
            controller.navigationItem.leftBarButtonItem = self.backButton;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
            [self presentModalViewController:nav
                                    animated:YES];
            [[BaiduMobStat defaultStat] pageviewStartWithName:controller.title];
        }
        else {
            if ([controllerClass conformsToProtocol:@protocol(AppAction)]) {
                id<AppAction> app = [[controllerClass alloc] init];
                [app launchWithController:self];
            }
        }
    }
    else {
        [SVProgressHUD showImage:[UIImage imageNamed:@"cry.png"]
                          status:@"还木有实现哦，亲！"];
    }
}

- (void)grow
{
    CAKeyframeAnimation *growAnimation = [CAKeyframeAnimation animationScaleFrom:CGFLOAT_MIN
                                                                              to:1.0f
                                                                        duration:1.0
                                                                          frames:32
                                                                 withTimingBlock:CLElasticOutTimingFunction];
    for (CALayer *layer in iconLayers) {
        layer.hidden = NO;
        [layer addAnimation:growAnimation
                     forKey:@"GrowAnimation"];
    }
    iconLayers = nil;
}

#pragma mark - Appicon Delegate

- (void)AppiconDidPressed:(Appicon *)icon
{
    [self launchApplication:icon.action];
}

#pragma mark - Button Actions Here!

-(IBAction)onPageChanged:(id)sender
{
    isPageChanging = YES;
    CGRect frame = self.scroll.frame;
    [self.scroll setContentOffset:CGPointMake(frame.size.width*self.pageControl.currentPage, 0)
                         animated:YES];
}

- (IBAction)onBackHome:(id)sender
{
    self.modalViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self dismissModalViewControllerAnimated:YES];
    [[BaiduMobStat defaultStat] pageviewEndWithName:self.presentedViewController.title];
}

- (IBAction)onInfo:(id)sender
{
    AboutViewController *about = [[AboutViewController alloc] init];
    about.navigationItem.leftBarButtonItem = self.backButton;
    about.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:about];
    [self presentViewController:nav
                       animated:YES
                     completion:NULL];
}

#pragma mark - Actions

- (void)launchApplicationWithIndex:(int)appIdx
{
    NSArray *apps = [self loadApplications];
    if (appIdx < 0 || appIdx >= apps.count)
        return;
    
    NSDictionary *appInfo = [apps objectAtIndex:appIdx];
    
    if (self.presentedViewController && [self.presentedViewController isKindOfClass:NSClassFromString([appInfo valueForKey:@"AppAction"])]) {       // 用户正在需要打开的页面上
        
    }
    else if (self.presentedViewController) {           // 用户不在需要打开的页面上
        [[BaiduMobStat defaultStat] pageviewEndWithName:self.presentedViewController.title];
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     [self launchApplicationWithIndex:appIdx];
                                 }];
    }
    if ([NSThread isMainThread])
        [self launchApplication:[appInfo valueForKey:@"AppAction"]];
    else
        [self performSelectorOnMainThread:@selector(launchApplication:)
                               withObject:[appInfo valueForKey:@"AppAction"]
                            waitUntilDone:NO];
}

@end
