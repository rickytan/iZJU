//
//  Appicon.m
//  iZJU
//
//  Created by sheng tan on 12-10-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Appicon.h"

#define ICON_LABLE_HEIGHT 21.0f

@implementation Appicon

@synthesize action = _action;

+ (id)appiconWithImage:(UIImage *)image 
                 label:(NSString *)text
{
    return [[Appicon alloc] initWithImage:image label:text];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGSize size = frame.size;
        size.height = size.width;
        CGRect square = CGRectZero;
        square.size = size;
        
        iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        iconButton.frame = square;
        iconButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        iconButton.contentMode = UIViewContentModeScaleAspectFit;
        iconButton.showsTouchWhenHighlighted = NO;
        iconButton.adjustsImageWhenHighlighted = YES;
        iconButton.adjustsImageWhenDisabled = YES;
        iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.height - ICON_LABLE_HEIGHT, 0, frame.size.width, ICON_LABLE_HEIGHT)];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image 
              label:(NSString *)text
{
    if (self = [self initWithFrame:CGRectMake(0, 0, 60, 60+21)]) {
        [self setImage:image
                 label:text];
    }
    return self;
}

- (void)setImage:(UIImage *)image
           label:(NSString *)text
{
    [iconButton setImage:image
                forState:UIControlStateNormal];
    [iconLabel setText:text];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (IBAction)iconPressed:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    
    CAKeyframeAnimation *shrinkAnimation = [CAKeyframeAnimation animationScaleFrom:1.2
                                                                                to:1.0
                                                                          duration:0.6
                                                                            frames:32
                                                                   withTimingBlock:CLElasticOutTimingFunction];
    [btn.layer addAnimation:shrinkAnimation
                     forKey:@"Shrink"];
    btn.layer.transform = CATransform3DIdentity;
    
    if ([self.delegate respondsToSelector:@selector(AppiconDidPressed:)])
        [self.delegate AppiconDidPressed:self];
}

- (IBAction)iconTouchDown:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    CAKeyframeAnimation *shrinkAnimation = [CAKeyframeAnimation animationScaleFrom:1.0
                                                                                to:1.2
                                                                          duration:0.6
                                                                            frames:32
                                                                   withTimingBlock:CLElasticOutTimingFunction];
    [btn.layer addAnimation:shrinkAnimation
                     forKey:@"Grow"];
    btn.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0);
}

- (IBAction)iconTouchUp:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    CAKeyframeAnimation *shrinkAnimation = [CAKeyframeAnimation animationScaleFrom:1.2
                                                                                to:1.0
                                                                          duration:0.6
                                                                            frames:32
                                                                   withTimingBlock:CLElasticOutTimingFunction];
    [btn.layer addAnimation:shrinkAnimation
                     forKey:@"Shrink"];
    btn.layer.transform = CATransform3DIdentity;
}

@end
