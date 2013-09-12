//
//  Appicon.h
//  iZJU
//
//  Created by sheng tan on 12-10-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Appicon;

@protocol AppiconDelegate <NSObject>

- (void)AppiconDidPressed:(Appicon*)icon;

@end

@interface Appicon : UIView
{
    IBOutlet UIButton        * iconButton;
    IBOutlet UILabel         * iconLabel;
}

@property (nonatomic, assign) IBOutlet id<AppiconDelegate> delegate;
@property (nonatomic, strong) NSString *action;

+ (id)appiconWithImage:(UIImage*)image 
                 label:(NSString*)text;
- (id)initWithImage:(UIImage*)image 
              label:(NSString*)text;
- (void)setImage:(UIImage*)image
           label:(NSString*)text;

- (IBAction)iconPressed:(id)sender;
- (IBAction)iconTouchDown:(id)sender;
- (IBAction)iconTouchUp:(id)sender;

@end
