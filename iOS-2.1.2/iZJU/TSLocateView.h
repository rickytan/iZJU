//
//  UICityPicker.h
//  DDMates
//
//  Created by ShawnMa on 12/16/11.
//  Copyright (c) 2011 TelenavSoftware, Inc. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>


@interface TSLocateView : UIActionSheet <UIPickerViewDelegate, UIPickerViewDataSource> {
@private
    NSArray         * campuses;
    UIView          * filter;
    
    IBOutlet UILabel *titleLabel;
    IBOutlet UIPickerView *locatePicker;
}
@property (strong, nonatomic) NSString *fromCampus;
@property (strong, nonatomic) NSString *toCampus;

- (id)initWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate;

- (void)showInView:(UIView *)view;
- (void)initSelect:(NSString*)from
              with:(NSString*)to;

- (IBAction)cancel:(id)sender;
@end
