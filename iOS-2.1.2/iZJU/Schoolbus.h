//
//  Schoolbus.h
//  iZJU
//
//  Created by 爱机 on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "ZJUSchoolBusDataRequest.h"
#import "SchoolBusSearchResultViewController.h"
#import "TSLocateView.h"

@interface Schoolbus : UIViewController
<UIActionSheetDelegate,
SchoolBusSearchResultViewControllerDelegate,
UITextFieldDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
ZJUDateRequestDelegate>
{
    IBOutlet UIButton       * search;
    IBOutlet UIButton       * toButton;
    IBOutlet UIButton       * fromButton;
    IBOutlet UIButton       * changeFromTo;
    IBOutlet UIView         * rotatorView;
    IBOutlet UITextField    * busSelecterView;
    IBOutlet UIView         * flipView;
    TSLocateView            * pickerCampus;
    
    BOOL                      isSearchBusType;
    
    NSArray                 * _cachedBusInfo;
    NSArray                 * _buses;
}
@property (nonatomic, readonly) NSArray *cachedBusInfo;
@property (nonatomic, readonly) NSArray *buses;

-(IBAction)fromWhere:(id)sender;
-(IBAction)toWhere:(id)sender;
-(IBAction)changeForFromto:(id)sender;
-(IBAction)searchBus:(id)sender;

-(IBAction)swipeUp:(id)sender;
-(IBAction)swipeDown:(id)sender;

-(IBAction)hideInputView:(id)sender;

@end
