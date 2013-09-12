//
//  AppHelper.h
//  iZJU
//
//  Created by sheng tan on 12-10-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#define RGB(__r,__g,__b) [UIColor colorWithRed:(__r) green:(__g) blue:(__b) alpha:1.0f]


@interface AppHelper : NSObject <UIActionSheetDelegate>

+ (id)sharedHelper;
+ (void)makeACallTo:(NSString*)number;
- (void)showCallerSheetWithTitle:(NSString*)title
                          number:(NSString*)numberOrNumbers;

@end


@interface NSString (Extension)
+ (BOOL)isNullOrEmpty:(NSString*)string;
- (NSString*)md5;
- (NSString*)stringByReplaceStringWithChar:(const char)p;
+ (NSString*)uniqueString;
+ (NSString*)documentsPath;
+ (NSString*)libraryPath;
+ (NSString*)cachePath;
+ (NSString*)downloadPath;
+ (NSString*)tmpPath;

@end

@interface NSData (Extension)
- (NSString*)base64String;
@end

@interface UIView (Extension)
- (void)chilingAnimation;
@end

static NSString *const UIDeviceDidShakeNotification = @"UIDeviceDidShakeNotification";

@interface UIWindow (Extension)

@end

typedef CGFloat (^TimingBlock)(CGFloat);

extern const TimingBlock CLElasticOutTimingFunction;
extern const TimingBlock CLEaseOutBounceTimingFunction;

@interface CAKeyframeAnimation (CLAnimation)
+ (id)animationKeyPath:(NSString*)keyPath
                  From:(double)start
                    to:(double)end
              duration:(NSTimeInterval)duration
                frames:(NSInteger)frames
       withTimingBlock:(TimingBlock)block;
+ (id)animationRotateFrom:(CGFloat)start
                       to:(CGFloat)end
                 duration:(NSTimeInterval)duration
                   frames:(NSInteger)frames
          withTimingBlock:(TimingBlock)block;

+ (id)animationPositionFrom:(CGPoint)start
                         to:(CGPoint)end
                   duration:(NSTimeInterval)duration
                     frames:(NSInteger)frames
            withTimingBlock:(TimingBlock)block;
+ (id)animationPositionWithPath:(CGPathRef)path
                       duration:(NSTimeInterval)duration
                         frames:(NSInteger)frames
                withTimingBlock:(TimingBlock)block;
+ (id)animationScaleFrom:(CGFloat)start
                      to:(CGFloat)end
                duration:(NSTimeInterval)duration
                  frames:(NSInteger)frames
         withTimingBlock:(TimingBlock)block;
@end