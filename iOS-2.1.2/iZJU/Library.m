//
//  Library.m
//  iZJU
//
//  Created by ricky on 12-11-23.
//
//

#import "Library.h"

@interface Library ()
- (void)updateButton;
- (void)webNavigationButton:(id)sender;
@property (nonatomic, assign) IBOutlet UIWebView *webView;
@end

@implementation Library
@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"浙大图书馆";
    }
    return self;
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

- (BOOL)isFirstLaunch
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL result = [userDefault boolForKey:@"has_library_launched"];
    if (!result) {
        [userDefault setBool:YES
                      forKey:@"has_library_launched"];
        [userDefault synchronize];
    }
    return !result;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem *waitItem = [[UIBarButtonItem alloc] initWithCustomView:spinnerView];
    
    segmentView = [[UISegmentedControl alloc] initWithItems:@[
                   [UIImage imageNamed:@"arrowleft.png"],
                   [UIImage imageNamed:@"arrowright.png"]]
                   ];
    segmentView.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentView.momentary = YES;
    segmentView.enabled = YES;
    [segmentView addTarget:self
                    action:@selector(webNavigationButton:)
          forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *segmentItem = [[UIBarButtonItem alloc] initWithCustomView:segmentView];
    self.navigationItem.rightBarButtonItems = @[segmentItem,waitItem];
    
    NSURL *libSite = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"id_library_link"]];
    
    if (!libSite) {
        libSite = [NSURL URLWithString:@"http://zju.superlib.com"];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:libSite];
    [self.webView loadRequest:request];
    
    if ([self isFirstLaunch]) {
        [[[UIAlertView alloc] initWithTitle:@"小提示"
                                    message:@"您可以在“设置”中修改图书馆后台哦！"
                                   delegate:nil
                          cancelButtonTitle:@"知道了"
                          otherButtonTitles:nil] show];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.webView stopLoading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)updateButton
{
    [segmentView setEnabled:self.webView.canGoBack
          forSegmentAtIndex:0];
    [segmentView setEnabled:self.webView.canGoForward
          forSegmentAtIndex:1];
}

- (void)webNavigationButton:(id)sender
{
    if (segmentView.selectedSegmentIndex == 0)
        [self.webView goBack];
    else if (segmentView.selectedSegmentIndex == 1)
        [self.webView goForward];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self updateButton];
    [spinnerView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self updateButton];
    [spinnerView stopAnimating];
}

- (void)webView:(UIWebView *)webView
didFailLoadWithError:(NSError *)error
{
    
    [self updateButton];
    [spinnerView stopAnimating];
    if (error.code != NSURLErrorCancelled) {
        [[[UIAlertView alloc] initWithTitle:@"无法加载"
                                    message:@"请确定您的网络正常连接！"
                                   delegate:nil
                          cancelButtonTitle:@"好"
                          otherButtonTitles:nil] show];
    }
}

@end
