//
//  Feedback.m
//  iZJU
//
//  Created by ricky on 12-11-8.
//
//

#import <QuartzCore/QuartzCore.h>
#import "Feedback.h"
#import "SVProgressHUD.h"
#import "MBProgressHUD.h"

@interface Feedback ()

- (IBAction)handlerEmailFieldChange:(id)sender;
- (IBAction)onGotoComment:(id)sender;
- (void)onSubmit:(id)sender;

@property (nonatomic, strong) MBProgressHUD *mbHUD;

@end

@implementation Feedback
@synthesize mbHUD = _mbHUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"建议反馈";
        isEmailValid = YES;
        
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
	// Do any additional setup after loading the view.
    
    textView.layer.cornerRadius = 8.0f;
    
    UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithTitle:@"发送"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(onSubmit:)];
    self.navigationItem.rightBarButtonItem = submit;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter & setter

- (MBProgressHUD*)mbHUD
{
    _mbHUD = [MBProgressHUD HUDForView:self.view];
    if (!_mbHUD) {
        _mbHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _mbHUD.margin = 10.;
        _mbHUD.mode = MBProgressHUDModeText;
        _mbHUD.animationType = MBProgressHUDAnimationZoom;
        _mbHUD.yOffset = -64.;
        [self.view addSubview:_mbHUD];
    }
    return _mbHUD;
}

#pragma mark - Actions

- (IBAction)handlerEmailFieldChange:(id)sender
{
    if (![NSString isNullOrEmpty:textField.text]) {
        NSString *regExp = @"[a-zA-Z0-9._%+-]+@([A-Za-z0-9-]+\\.)+[a-zA-Z]{2,4}";
        NSPredicate *match = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regExp];
        isEmailValid = [match evaluateWithObject:textField.text];
        if (isEmailValid) {
            textField.backgroundColor = [UIColor whiteColor];
        }
        else
            textField.backgroundColor = [UIColor yellowColor];
    }
    else {
        textField.backgroundColor = [UIColor whiteColor];
        isEmailValid = YES;
    }
}

- (void)onSubmit:(id)sender
{
    if (!isEmailValid) {
        self.mbHUD.labelText = @"您的邮箱地址有误哦...";
        [self.mbHUD show:YES];
        [self.mbHUD hide:YES
              afterDelay:1.0];
        return;
    }
    if ([NSString isNullOrEmpty:textView.text]) {
        self.mbHUD.labelText = @"请写点东西再提交吧亲！";
        [self.mbHUD show:YES];
        [self.mbHUD hide:YES
              afterDelay:1.0];
        return;
    }
    [textView resignFirstResponder];
    [textField resignFirstResponder];
    
    ZJUFeedbackPost *request = [ZJUFeedbackPost dataRequest];
    request.email = textField.text;
    request.message = textView.text;
    
    [[ZJUDataServer sharedServer] executeRequest:request
                                        delegate:self];
    [SVProgressHUD setStatus:@"发送中..."];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
}

- (IBAction)onGotoComment:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=573810521"];
    [[UIApplication sharedApplication] openURL:url];
}


#pragma mark - ZJUDateRequest delegate

- (void)requestDidFailed:(ZJUDataRequest *)request withError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"矮油，貌似失败了...再试试啦"];
}

- (void)requestDidFinished:(ZJUDataRequest *)request
                  withData:(id)data
{
    if ([[data objectForKey:@"success"] boolValue]) {
        [SVProgressHUD showSuccessWithStatus:@"感谢您的宝贵建议！"];
        textField.text = nil;
        textView.text = nil;
    }
    else {
        self.mbHUD.labelText = @"发送失败！";
        self.mbHUD.detailsLabelText = @"请填写内容";
        [self.mbHUD show:YES];
        [self.mbHUD hide:YES
              afterDelay:1.0];
    }
}

@end
