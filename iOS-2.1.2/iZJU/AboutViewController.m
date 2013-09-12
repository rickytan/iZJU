//
//  AboutViewController.m
//  iZJU
//
//  Created by ricky on 12-12-5.
//
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *currVersion = [appInfo valueForKey:@"CFBundleVersion"];
    _versionLabel.text = [NSString stringWithFormat:@"Version %@",currVersion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onEmail:(id)sender
{
    NSString *email = @"mailto:contact@izju.org?subject=iZJU反馈";
    [[UIApplication sharedApplication] openURL:
     [NSURL URLWithString:
      [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

- (IBAction)onSite:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.izju.org"]];
}

@end
