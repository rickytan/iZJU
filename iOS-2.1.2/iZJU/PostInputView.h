//
//  PostInputView.h
//  iZJU
//
//  Created by ricky on 12-11-29.
//
//

#import <UIKit/UIKit.h>

@class PostInputView;

@protocol PostInputViewDelegate <NSObject>

- (void)postInputViewDidPressSend:(PostInputView*)view;

@end

@interface PostInputView : UIView
{
    IBOutlet UIButton                   * _postButton;
    IBOutlet UITextField                * _textField;
}
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *postButton;

@property (nonatomic, assign) id<PostInputViewDelegate> delegate;

@end
