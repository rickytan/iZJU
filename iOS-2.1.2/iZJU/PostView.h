//
//  PostView.h
//  iZJU
//
//  Created by ricky on 12-11-29.
//
//

#import <UIKit/UIKit.h>
#import "PostInputView.h"

@class PostView;

@protocol PostViewDelegate <NSObject>

- (void)postViewDidTapStar:(PostView*)postView;
- (void)postViewDidTapSend:(PostView*)postView;

@end

@interface PostView : UIControl <UITextFieldDelegate, PostInputViewDelegate>
{
    IBOutlet UITextField                    * _textField;
    IBOutlet UIButton                       * _starButton;
}

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *starButton;
@property (nonatomic, assign) id<PostViewDelegate> delegate;

@end
