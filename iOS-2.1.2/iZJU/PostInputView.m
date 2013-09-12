//
//  PostInputView.m
//  iZJU
//
//  Created by ricky on 12-11-29.
//
//

#import "PostInputView.h"
#import <QuartzCore/QuartzCore.h>

@interface PostInputView ()

- (IBAction)onSend:(id)sender;

@end

@implementation PostInputView
@synthesize textField = _textField;
@synthesize postButton = _postButton;

- (void)awakeFromNib
{
    UIImage *bg = [[UIImage imageNamed:@"post_input.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];

    [_textField setBackground:bg];
    UIFont *font = [UIFont fontWithName:@"FZKaTong-M19S"
                                   size:12.0];
    [_textField setFont:font];
    
    UIView *leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 18)];
    [_textField setLeftView:leftview];
    [_textField setLeftViewMode:UITextFieldViewModeAlways];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}

- (id)init
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PostInputView"
                                                   owner:nil
                                                 options:nil];
    for (id obj in array) {
        if ([obj isKindOfClass:[PostInputView class]]) {
            return obj;
            break;
        }
    }
    return nil;
}

- (BOOL)becomeFirstResponder
{
    return [_textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [_textField resignFirstResponder];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Actions

- (IBAction)onSend:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(postInputViewDidPressSend:)])
        [self.delegate postInputViewDidPressSend:self];
}

@end
