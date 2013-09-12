//
//  BaikeDetailViewController.m
//  iZJU
//
//  Created by ricky on 12-11-10.
//
//

#import "BaikeDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BaikeDetailViewController ()

@property (strong, nonatomic) IBOutlet UILabel *detailTitleLabel;
@property (strong, nonatomic) IBOutlet UITextView *detailContentView;
@end

@implementation BaikeDetailViewController
@synthesize detailTitleLabel, detailContentView;
@synthesize wikiDetail,wikiTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"详情";
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
    
    self.detailContentView.layer.cornerRadius = 8.0f;
    
    self.detailTitleLabel.text = self.wikiTitle;
    self.detailContentView.text = self.wikiDetail;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
