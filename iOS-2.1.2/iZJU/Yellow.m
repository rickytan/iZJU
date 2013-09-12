//
//  Yellow.m
//  iZJU
//
//  Created by ricky on 13-1-25.
//
//

#import "Yellow.h"
#import "Telephone.h"
#import "SearchPhoneController.h"
#import "ZipArchive.h"
#import "BaiduMobStat.h"

@interface Yellow ()
@property (nonatomic, strong) IBOutlet UITabBarController *tabController;
@end

@implementation Yellow
@synthesize tabController = _tabController;

- (void)dealloc
{
    self.tabController = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"浙大黄页";
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
    
    self.navigationController.navigationBarHidden = YES;
    
    [self addChildViewController:self.tabController];
    [self initSQLiteDBInBackground];
}

- (void)initSQLiteDBInBackground
{
    [self performSelectorInBackground:@selector(initSQLite)
                           withObject:nil];
}

- (void)initSQLite
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [Telephone telephoneDBPath];
    if (![fm fileExistsAtPath:path]) {
        NSString *dbResource = [[NSBundle mainBundle] pathForResource:@"zjutel-db"
                                                               ofType:@"zip"];
        ZipArchive *zip = [[ZipArchive alloc] init];
        if (![zip UnzipOpenFile:dbResource]) {
            NSLog(@"数据文件打开错误！");
        }
        if (![zip UnzipFileTo:[path stringByDeletingLastPathComponent]
                    overWrite:YES]) {
            NSLog(@"数据文件解压错误！");
        }
        [zip UnzipCloseFile];
    }
    
    [self performSelectorOnMainThread:@selector(initDidFinished)
                           withObject:nil
                        waitUntilDone:NO];
}

- (void)initDidFinished
{
    self.tabController.view.frame = self.view.bounds;
    [self.view addSubview:self.tabController.view];
}

#pragma mark - Actions

- (IBAction)onDismiss:(id)sender
{
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self dismissModalViewControllerAnimated:YES];
    [[BaiduMobStat defaultStat] pageviewEndWithName:self.title];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(UIViewController *)viewController
{
    [[BaiduMobStat defaultStat] pageviewEndWithName:tabBarController.selectedViewController.title];
    [[BaiduMobStat defaultStat] pageviewStartWithName:viewController.title];
    return YES;
}

@end
