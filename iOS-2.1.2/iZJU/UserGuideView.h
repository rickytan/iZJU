//
//  UserGuideView.h
//  iZJU
//
//  Created by ricky on 12-12-5.
//
//

#import <UIKit/UIKit.h>

@class UserGuideView;

@protocol UserGuideViewDelegate <NSObject>

- (void)UserGuideDidFinish:(UserGuideView*)guideview;

@end

@interface UserGuideView : UIView <UIScrollViewDelegate>
{
    int                     count;
}
@property (nonatomic, assign) id<UserGuideViewDelegate> delegate;

- (id)initWithImages:(NSArray*)images;

@end
