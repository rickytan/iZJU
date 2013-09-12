//
//  AppHelper.m
//  iZJU
//
//  Created by sheng tan on 12-10-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppHelper.h"
#import <CommonCrypto/CommonDigest.h>

static AppHelper * theInstance = nil;

@implementation AppHelper

+ (id)sharedHelper
{
    @synchronized(self) {
        if (!theInstance) {
            theInstance = [[AppHelper alloc] init];
        }
        return theInstance;
    }
    return nil;
}

+ (void)makeACallTo:(NSString*)number
{
    NSURL *url = [NSURL URLWithString:[@"tel://" stringByAppendingString:number]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Can't make a Call"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)showCallerSheetWithTitle:(NSString*)title
                          number:(NSString*)numberOrNumbers
{
    NSString *tel = numberOrNumbers;
    if ([NSString isNullOrEmpty:tel]) {
        return;
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [UIApplication sharedApplication].windows.lastObject;
    }
    
    NSArray *numbers = [tel componentsSeparatedByString:@"/"];
    if (numbers.count < 2) {
        UIActionSheet *callAction = [[UIActionSheet alloc] initWithTitle:title
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                  destructiveButtonTitle:numbers.lastObject
                                                       otherButtonTitles:nil];
        [callAction showInView:window];
    }
    else {
        UIActionSheet *callAction = [[UIActionSheet alloc] init];
        [callAction setTitle:title];
        
        for (NSString *num in numbers) {
            [callAction addButtonWithTitle:num];
        }
        callAction.cancelButtonIndex = [callAction addButtonWithTitle:@"取消"];
        callAction.delegate = self;
        [callAction showInView:window];
    }
}


#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSString *num = [actionSheet buttonTitleAtIndex:buttonIndex];
        [AppHelper makeACallTo:num];
    }
}

@end


@implementation NSString (Extension)

+ (BOOL)isNullOrEmpty:(NSString*)string
{
    BOOL rtnval = (string == nil) || [string isEqualToString:@""];
    return rtnval;
}

- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int) strlen(cStr), result);
    return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}

- (NSString *)stringByReplaceStringWithChar:(const char)p
{
    static char text[1024] = {0};
    if ([self getCString:text
               maxLength:1023
                encoding:NSUTF8StringEncoding]) {
        char *ptext = text;
        while (*ptext) {
            *(ptext++) = p;
        }
        return [NSString stringWithCString:text
                                  encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (NSString*) uniqueString
{
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);
	NSString	*uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return uuidString;
}

+ (NSString*)documentsPath
{
    static NSString *documentsPath = nil;
    if (documentsPath)
        return documentsPath;
    
    documentsPath = [[NSBundle mainBundle] resourcePath];
    documentsPath = [[documentsPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Documents"];
    return documentsPath;
}

+ (NSString*)libraryPath
{
    static NSString *libraryPath = nil;
    if (libraryPath)
        return libraryPath;
    
    libraryPath = [[NSBundle mainBundle] resourcePath];
    libraryPath = [[libraryPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Library"];
    return libraryPath;
}

+ (NSString*)cachePath
{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
}

+ (NSString*)downloadPath
{
    static NSString *downloadPath = nil;
    if (downloadPath)
        return downloadPath;
    
    NSArray *pathes = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, NO);
    downloadPath = [pathes objectAtIndex:0];
    return downloadPath;
}

+ (NSString*)tmpPath
{
    static NSString *tmpPath = nil;
    if (tmpPath)
        return tmpPath;
    
    tmpPath = [[NSBundle mainBundle] resourcePath];
    tmpPath = [[tmpPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"tmp"];
    return tmpPath;
}

@end

@implementation NSData (Extension)

- (NSString*)base64String
{
    const uint8_t* input = (const uint8_t*)[self bytes];
    NSInteger length = [self length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    return [NSString stringWithUTF8String:data.bytes];
}

@end

@implementation UIView (Extension)

- (void)chilingAnimation
{
    CGPoint center = self.center;
    center.x += 24.f;
    
    TimingBlock block = ^float(float ratio) {
        if (ratio == 0.0f || ratio == 1.0f)
            return ratio;
        else
        {
            float p = 0.1f;
            float s = p / 4.0f;
            return powf(2.0f, -8.0f*ratio) * sinf((ratio-s)*2*M_PI/p) + 1.0f;
        }
    };
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationPositionFrom:center
                                                                             to:self.center
                                                                       duration:1.2
                                                                         frames:32
                                                                withTimingBlock:block];
    [self.layer addAnimation:animation
                      forKey:@"chilling"];
}

@end

@implementation UIWindow (Extension)

static NSTimeInterval lastShakeTime = 0;

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (lastShakeTime > 0 && event.timestamp - lastShakeTime < 1.0)
        return;
    
    lastShakeTime = event.timestamp;
	if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
		[[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceDidShakeNotification
                                                            object:self];
	}
}

@end


const TimingBlock CLElasticOutTimingFunction = ^CGFloat(CGFloat ratio) {
    if (ratio == 0.0f || ratio == 1.0f)
        return ratio;
    else
    {
        float p = 0.4f;
        float s = p / 4.0f;
        return powf(2.0f, -8.0f*ratio) * sinf((ratio-s)*2*M_PI/p) + 1.0f;
    }
};

const TimingBlock CLEaseOutBounceTimingFunction = ^CGFloat(CGFloat ratio) {
    float s = 7.5625f;
    float p = 2.75f;
    float l;
    if (ratio < (1.0f/p))
    {
        l = s * powf(ratio, 2.0f);
    }
    else
    {
        if (ratio < (2.0f/p))
        {
            ratio -= 1.5f/p;
            l = s * powf(ratio, 2.0f) + 0.75f;
        }
        else
        {
            if (ratio < 2.5f/p)
            {
                ratio -= 2.25f/p;
                l = s * powf(ratio, 2.0f) + 0.9375f;
            }
            else
            {
                ratio -= 2.625f/p;
                l = s * powf(ratio, 2.0f) + 0.984375f;
            }
        }
    }
    return l;
};

@implementation CAKeyframeAnimation (CLAnimation)
+ (id)animationKeyPath:(NSString *)keyPath
                  From:(double)start
                    to:(double)end
              duration:(NSTimeInterval)duration
                frames:(NSInteger)frames
       withTimingBlock:(TimingBlock)block
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    animation.calculationMode = kCAAnimationLinear;
    animation.repeatCount = 0;
    animation.duration = duration;
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:frames];
    CGFloat time = 0.0f;
    NSAssert(frames > 1,@"Frames must be larger than 1");
    CGFloat timeStep = 1.0f / (frames - 1);
    double delta = end - start;
    for (int i=0; i<frames ; ++i) {
        double v = start + block(time)*delta;
        [values addObject:[NSNumber numberWithDouble:v]];
        time += timeStep;
    }
    animation.values = values;
    
    return animation;
}

+ (id)animationRotateFrom:(CGFloat)start
                       to:(CGFloat)end
                 duration:(NSTimeInterval)duration
                   frames:(NSInteger)frames
          withTimingBlock:(TimingBlock)block
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.calculationMode = kCAAnimationLinear;
    animation.repeatCount = 0;
    animation.duration = duration;
    animation.removedOnCompletion = YES;
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:frames];
    CGFloat time = 0.0f;
    NSAssert(frames > 1,@"Frames must be larger than 1");
    CGFloat timeStep = 1.0f / (frames - 1);
    double delta = end - start;
    
    for (int i=0; i<frames ; ++i) {
        CATransform3D p = CATransform3DRotate(CATransform3DIdentity, start+delta*block(time), 0, 0, 1);
        [values addObject:[NSValue valueWithCATransform3D:p]];
        time += timeStep;
    }
    animation.values = values;
    
    return animation;
}

+ (id)animationPositionFrom:(CGPoint)start
                         to:(CGPoint)end
                   duration:(NSTimeInterval)duration
                     frames:(NSInteger)frames
            withTimingBlock:(TimingBlock)block
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.calculationMode = kCAAnimationLinear;
    animation.repeatCount = 0;
    animation.duration = duration;
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:frames];
    CGFloat time = 0.0f;
    NSAssert(frames > 1,@"Frames must be larger than 1");
    CGFloat timeStep = 1.0f / (frames - 1);
    CGPoint delta = CGPointMake(end.x - start.x, end.y - start.y);
    for (int i=0; i<frames ; ++i) {
        CGPoint p = CGPointMake(start.x + block(time)*delta.x,
                                start.y + block(time)*delta.y);
        [values addObject:[NSValue valueWithCGPoint:p]];
        time += timeStep;
    }
    animation.values = values;
    
    return animation;
}

+ (id)animationPositionWithPath:(CGPathRef)path
                       duration:(NSTimeInterval)duration
                         frames:(NSInteger)frames
                withTimingBlock:(TimingBlock)block
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.calculationMode = kCAAnimationLinear;
    animation.repeatCount = 0;
    animation.duration = duration;
    
    animation.path = path;
    
    return animation;
}

+ (id)animationScaleFrom:(CGFloat)start
                      to:(CGFloat)end
                duration:(NSTimeInterval)duration
                  frames:(NSInteger)frames
         withTimingBlock:(TimingBlock)block
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.calculationMode = kCAAnimationLinear;
    animation.repeatCount = 0;
    animation.duration = duration;
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:frames];
    CGFloat time = 0.0f;
    NSAssert(frames > 1,@"Frames must be larger than 1");
    CGFloat timeStep = 1.0f / (frames - 1);
    CGFloat delta = end - start;
    for (int i=0; i<frames ; ++i) {
        CGFloat f = start + block(time)*delta;
        CATransform3D transform = CATransform3DMakeScale(f, f, 1);
        [values addObject:[NSValue valueWithCATransform3D:transform]];
        time += timeStep;
    }
    animation.values = values;
    
    return animation;
}

@end