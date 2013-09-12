//
//  PostView.m
//  iZJU
//
//  Created by ricky on 12-11-29.
//
//

#import "PostView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PostView
@synthesize textField = _textField;
@synthesize starButton = _starButton;

- (void)awakeFromNib
{
    self.layer.shadowOffset = CGSizeMake(0, -2);
    
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 18)];
    leftView.contentMode = UIViewContentModeRight;
    leftView.image = [UIImage imageNamed:@"post_write.png"];
    [_textField setLeftView:leftView];
    [_textField setLeftViewMode:UITextFieldViewModeAlways];
    UIFont *font = [UIFont fontWithName:@"FZKaTong-M19S"
                                   size:12.0];
    [_textField setFont:font];
    PostInputView *postInputView = [[PostInputView alloc] init];
    postInputView.delegate = self;
    postInputView.textField.delegate = self;
    [_textField setInputAccessoryView:postInputView];
    
    UIImage *bg = [[UIImage imageNamed:@"post_input.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    
    [_textField setBackground:bg];

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
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PostView"
                                                   owner:nil
                                                 options:nil];
    for (id obj in array) {
        if ([obj isKindOfClass:[PostView class]]) {
            return obj;
            break;
        }
    }
    return nil;
}

- (void)dealloc
{
    [self resignFirstResponder];
    ((PostInputView*)_textField.inputAccessoryView).textField.delegate = nil;
    [_textField setInputAccessoryView:nil];
}

- (BOOL)resignFirstResponder
{
    if (![_textField resignFirstResponder])
        return [_textField.inputAccessoryView resignFirstResponder];
    return YES;
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

- (IBAction)onStar:(id)sender
{
    _starButton.selected = !_starButton.isSelected;
    
    if ([self.delegate respondsToSelector:@selector(postViewDidTapStar::)])
        [self.delegate postViewDidTapStar:self];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _textField) {
        ((PostInputView*)_textField.inputAccessoryView).textField.text = _textField.text;
    }

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _textField) {
        //[_textField resignFirstResponder];
        [_textField.inputAccessoryView performSelector:@selector(becomeFirstResponder)
                                            withObject:nil
                                            afterDelay:0.1];
    }
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    if (textField != _textField) {
        _textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    }
    return YES;
}

#pragma mark - PostInputView Delegate

- (void)postInputViewDidPressSend:(PostInputView *)view
{
    if ([self.delegate respondsToSelector:@selector(postViewDidTapSend:)])
        [self.delegate postViewDidTapSend:self];
}

@end
