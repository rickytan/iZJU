//
//  UICityPicker.m
//  DDMates
//
//  Created by ShawnMa on 12/16/11.
//  Copyright (c) 2011 TelenavSoftware, Inc. All rights reserved.
//

#import "TSLocateView.h"

#define kDuration 0.3

@implementation TSLocateView

@synthesize fromCampus;
@synthesize toCampus;

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIActionSheetDelegate>*/)delegate
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"TSLocateView"
                                          owner:self
                                        options:nil] objectAtIndex:0];
    if (self) {
        self.delegate = delegate;
        titleLabel.text = title;
        campuses = [NSArray arrayWithObjects:@"紫金港",@"玉泉",@"西溪",@"之江",@"华家池", nil];
        
        [locatePicker selectRow:0
                    inComponent:0
                       animated:NO];
        self.fromCampus = [campuses objectAtIndex:0];
        [locatePicker selectRow:1
                    inComponent:1
                       animated:NO];
        self.toCampus = [campuses objectAtIndex:1];
    }
    return self;
}

- (void)showInView:(UIView *) view
{
    self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
    
    // self.locatePicker.dataSource = self;
    // self.locatePicker.delegate = self;
    
    filter = [[UIView alloc] initWithFrame:view.bounds];
    filter.backgroundColor = [UIColor blackColor];
    filter.alpha = 0.0f;
    filter.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(cancel:)];
    tap.numberOfTapsRequired = 1;
    [filter addGestureRecognizer:tap];
    
    [view addSubview:filter];
    
    [view addSubview:self];
    
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.transform = CGAffineTransformIdentity;
                         filter.alpha = 0.6f;
                     }
                     completion:NULL];
}

- (void)initSelect:(NSString *)from with:(NSString *)to
{
    if ([campuses containsObject:from]) {
        [locatePicker selectRow:[campuses indexOfObject:from]
                    inComponent:0
                       animated:NO];
        self.fromCampus = from;
    }
    if ([campuses containsObject:to]) {
        [locatePicker selectRow:[campuses indexOfObject:to]
                    inComponent:1
                       animated:NO];
        self.toCampus = to;
    }
}

#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return 5;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
        {
            return [campuses objectAtIndex:row];
        }
            break;
        case 1:
        {
            return [campuses objectAtIndex:row];
        }
            break;
        default:
            return nil;
            break;
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
        {
            NSInteger otherRow = [locatePicker selectedRowInComponent:1];
            if (otherRow == row) {
                otherRow = (otherRow == 0)?1:otherRow - 1;
                [locatePicker selectRow:otherRow
                            inComponent:1
                               animated:YES];
                self.toCampus = [campuses objectAtIndex:otherRow];
            }
            self.fromCampus = [campuses objectAtIndex:row];
            break;
        }
        case 1:
        {
            NSInteger otherRow = [locatePicker selectedRowInComponent:0];
            if (otherRow == row) {
                otherRow = (otherRow == 0)?1:otherRow - 1;
                [locatePicker selectRow:otherRow
                            inComponent:0
                               animated:YES];
                self.fromCampus = [campuses objectAtIndex:otherRow];
            }
            self.toCampus = [campuses objectAtIndex:row];
            break;
        }
        default:
            break;
    }
}


#pragma mark - Button lifecycle

- (IBAction)cancel:(id)sender {
    
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         filter.alpha = 0.0f;
                         self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         [filter removeFromSuperview];
                         filter = nil;
                         [self removeFromSuperview];
                     }];
    if(self.delegate) {
        [self.delegate actionSheet:self
              clickedButtonAtIndex:0];
    }
}

- (IBAction)locate:(id)sender {
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         filter.alpha = 0.0f;
                         self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         [filter removeFromSuperview];
                         filter = nil;
                         [self removeFromSuperview];
                     }];
    if(self.delegate) {
        [self.delegate actionSheet:self
              clickedButtonAtIndex:1];
    }
}

@end
