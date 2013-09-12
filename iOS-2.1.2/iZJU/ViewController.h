//
//  ViewController.h
//  iZJU
//
//  Created by 爱机 on 12-8-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Appicon.h"

@interface ViewController : UIViewController
<UIScrollViewDelegate,
AppiconDelegate>
{
    BOOL                isPageChanging;
    
    NSMutableArray     *iconLayers;
}

@property (strong,nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong,nonatomic) IBOutlet UIScrollView *scroll;
@property (strong,nonatomic) IBOutlet UIBarButtonItem *backButton;

-(IBAction)onPageChanged:(id)sender;
-(IBAction)onBackHome:(id)sender;
-(IBAction)onInfo:(id)sender;

- (void)launchApplicationWithIndex:(int)appIdx;

@end
