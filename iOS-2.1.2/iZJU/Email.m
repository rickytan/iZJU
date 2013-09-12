//
//  Email.m
//  iZJU
//
//  Created by ricky on 13-1-26.
//
//

#import "Email.h"
#import <ASIHTTPFramework/ASIHTTPFramework.h>
#import "SVProgressHUD.h"

@interface Email () <ASIHTTPRequestDelegate>
{
    BOOL                _loggedIn;
    
    ASIFormDataRequest  * loginRequest;
}

- (IBAction)onLogin:(id)sender;
- (IBAction)onCheckbox:(id)sender;

- (IBAction)onHideKeyboard:(id)sender;
@end

@implementation Email
@synthesize userField = _userField;
@synthesize passField = _passField;
@synthesize loginButton = _loginButton;
@synthesize checkboxButton = _checkboxButton;
@synthesize mailImage = _mailImage;
@synthesize webView = _webView;
@synthesize loginView = _loginView;

- (void)dealloc
{
    [loginRequest clearDelegatesAndCancel];
    loginRequest = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"浙大邮箱";
    }
    return self;
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass(self.class)
                          bundle:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.loginButton setBackgroundImage:[[UIImage imageNamed:@"blueButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)]
                                forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[[UIImage imageNamed:@"blueButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)]
                                forState:UIControlStateHighlighted];
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:iZJUUserEmailAccountKey];
    self.userField.text = [dic valueForKey:@"username"];
    self.passField.text = [dic valueForKey:@"password"];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onLogin:(id)sender
{
    NSString *user = self.userField.text;
    NSString *pass = self.passField.text;
    if ([NSString isNullOrEmpty:user]) {
        [self.userField chilingAnimation];
        [self.userField becomeFirstResponder];
    }
    else if ([NSString isNullOrEmpty:pass]) {
        [self.passField chilingAnimation];
        [self.passField becomeFirstResponder];
    }
    else {
        [SVProgressHUD show];
        
        [self.userField resignFirstResponder];
        [self.passField resignFirstResponder];
        
        if (self.checkboxButton.selected) {
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                                  user,@"username",
                                  pass,@"password", nil];
            [[NSUserDefaults standardUserDefaults] setObject:info
                                                      forKey:iZJUUserEmailAccountKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                                  user,@"username", nil];
            [[NSUserDefaults standardUserDefaults] setObject:info
                                                      forKey:iZJUUserEmailAccountKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.passField.text = nil;
        }
        
        NSURL *url = [NSURL URLWithString:@"http://mail.zju.edu.cn/coremail/login.jsp"];
        loginRequest = [ASIFormDataRequest requestWithURL:url];
        [loginRequest addPostValue:@"PHONE" forKey:@"service"];
        [loginRequest addPostValue:@"XJS" forKey:@"face"];
        [loginRequest addPostValue:@"/coremail/xphone/main.jsp" forKey:@"destURL"];
        [loginRequest addPostValue:user forKey:@"uid"];
        [loginRequest addPostValue:pass forKey:@"password"];
        [loginRequest addPostValue:@"login:" forKey:@"action"];
        loginRequest.delegate = self;
        loginRequest.timeOutSeconds = 8;
        [loginRequest startAsynchronous];
    }
}

- (IBAction)onCheckbox:(id)sender
{
    self.checkboxButton.selected = !self.checkboxButton.isSelected;
}

- (IBAction)onHideKeyboard:(id)sender
{
    [self.userField resignFirstResponder];
    [self.passField resignFirstResponder];
}


#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderWidth = 1.0;
    textField.layer.borderColor = RGB(130.0/255, 202.0/255, 114.0/255).CGColor;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.shadowOpacity = 0;
    textField.layer.borderWidth = 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.userField == textField) {
        [self.passField becomeFirstResponder];
    }
    else if (self.passField == textField) {
        if (![NSString isNullOrEmpty:self.userField.text])
            [self onLogin:nil];
        else
            [self.userField becomeFirstResponder];
    }
    return YES;
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.path isEqualToString:@"/coremail/xphone/logout.jsp"]) {
        _loggedIn = NO;

        [UIView transitionWithView:self.view
                          duration:0.35
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            [self.view bringSubviewToFront:self.loginView];
                        }
                        completion:NULL];
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView
didFailLoadWithError:(NSError *)error
{
    
}


#pragma mark - ASIHTTPRequest Delegate

- (void)request:(ASIHTTPRequest *)request
didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    
}

- (void)request:(ASIHTTPRequest *)request
willRedirectToURL:(NSURL *)newURL
{
    if ([newURL.path isEqualToString:@"/coremail/xphone/main.jsp"]) {
        for (NSHTTPCookie *cookie in [ASIHTTPRequest sessionCookies]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
        _loggedIn = YES;
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:newURL]];
        self.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.6
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.mailImage.alpha = 0.0;
                             CGAffineTransform tran = CGAffineTransformMakeTranslation(240, -200);
                             tran = CGAffineTransformRotate(tran, -M_PI);
                             self.mailImage.transform = tran;
                         }
                         completion:^(BOOL finished) {
                             [UIView transitionWithView:self.view
                                               duration:0.35
                                                options:UIViewAnimationOptionTransitionCrossDissolve
                                             animations:^{
                                                 [self.view bringSubviewToFront:self.webView];
                                             }
                                             completion:^(BOOL finished) {
                                                 self.mailImage.transform = CGAffineTransformIdentity;
                                                 self.mailImage.alpha = 1.0;
                                                 self.view.userInteractionEnabled = YES;
                                                 [SVProgressHUD dismiss];
                                             }];
                         }];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"用户名或密码错误！"];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if ([request.url.path isEqualToString:@"/coremail/login.jsp"]) {
        [SVProgressHUD showErrorWithStatus:@"用户名或密码错误！"];
    }
    else
        [SVProgressHUD showErrorWithStatus:@"未知错误！"];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    NSLog(@"%@",request.error);
}

@end
