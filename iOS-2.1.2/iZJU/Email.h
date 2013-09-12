//
//  Email.h
//  iZJU
//
//  Created by ricky on 13-1-26.
//
//

#import <UIKit/UIKit.h>

@interface Email : UIViewController <UITextFieldDelegate, UIWebViewDelegate>
@property (nonatomic, assign) IBOutlet UITextField *userField;
@property (nonatomic, assign) IBOutlet UITextField *passField;
@property (nonatomic, assign) IBOutlet UIButton *loginButton;
@property (nonatomic, assign) IBOutlet UIButton *checkboxButton;
@property (nonatomic, assign) IBOutlet UIImageView *mailImage;
@property (nonatomic, assign) IBOutlet UIWebView *webView;
@property (nonatomic, assign) IBOutlet UIView *loginView;
@end
