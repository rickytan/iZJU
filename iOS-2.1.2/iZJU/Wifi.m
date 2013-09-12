//
//  Wifi.m
//  iZJU
//
//  Created by ricky on 12-12-14.
//
//

#import "Wifi.h"
#import "WifiAccountViewController.h"
#import "MBProgressHUD.h"
#import <SystemConfiguration/CaptiveNetwork.h>

static NSString *const kZJUWiFiAccountKey = @"kZJUWiFiAccountKey";
static NSString *const kZJUWiFiDefaultAccountKey = @"kZJUWiFiDefaultAccountKey";

enum {
    UIAlertViewTagAccountManage = 137,
    UIAlertViewTagKickOut
};

@interface Wifi ()
{
    MBProgressHUD                   * _mbHud;
}
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, readonly) UIBarButtonItem *logoutItem;
@property (nonatomic, strong) ASIHTTPRequest *request;
- (void)onLogout:(id)sender;
- (NSArray*)supportedWIFI;
- (void)authIfNeeded;
- (void)authenticateToWIFI:(NSString*)SSID;
- (void)manageAccounts;
- (void)registerSupportedWiFiSSID;
- (void)kickOut;
@end

@implementation Wifi
@synthesize reachability = reachability;
@synthesize tableView = _tableView;
@synthesize logoutItem = _logoutItem;
@synthesize request = _request;

+ (NSString*)getSSID
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    CFDictionaryRef info = NULL;
    for (NSString *ifnam in ifs) {
        info = CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && CFDictionaryGetCount(info)) {
            break;
        }
    }
    NSString *ssid = [(__bridge NSDictionary*)info valueForKey:(NSString*)kCNNetworkInfoKeySSID];
    if (info)
        CFRelease(info);
    if (ifs)
        CFRelease((__bridge CFTypeRef)(ifs));
    return ssid;
}

+ (NSArray*)getSavedAccounts
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSArray *array = [user arrayForKey:kZJUWiFiAccountKey];
    return array;
}

+ (BOOL)saveAccount:(NSDictionary *)account
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableArray *accounts = [user mutableArrayValueForKey:kZJUWiFiAccountKey];
    [accounts addObject:account];
    return [user synchronize];
}

+ (void)setDefaultAccountIndex:(NSUInteger)index
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setInteger:index forKey:kZJUWiFiDefaultAccountKey];
    [user synchronize];
}

+ (BOOL)deleteAccountAtIndex:(NSInteger)index
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableArray *accounts = [user mutableArrayValueForKey:kZJUWiFiAccountKey];
    if ([Wifi defaultAccountIndex] == accounts.count - 1)
        if (accounts.count > 1)
            [Wifi setDefaultAccountIndex:accounts.count - 2];
    [accounts removeObjectAtIndex:index];
    return [user synchronize];
}

+ (NSInteger)defaultAccountIndex
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    return [user integerForKey:kZJUWiFiDefaultAccountKey];
}

+ (BOOL)updateAccount:(NSDictionary *)account
              atIndex:(NSInteger)index
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableArray *accounts = [user mutableArrayValueForKey:kZJUWiFiAccountKey];
    [accounts setObject:account
     atIndexedSubscript:index];
    return [user synchronize];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [reachability stopNotifier];
    reachability = nil;
    [self.request clearDelegatesAndCancel];
    self.request = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"WiFi认证";
        self.reachability = [Reachability reachabilityForInternetConnection];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkHandler:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkHandler:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [self.reachability startNotifier];
        
        
        authConfig = @{
                       @"CERNET" : @{
                               @"url" : @"http://58.206.223.129/cgi-bin/login?cmd=login",//@"https://securelogin.arubanetworks.com/cgi-bin/login",
                               @"logoutUrl" : @"http://58.206.223.129/cgi-bin/login?cmd=logout",
                               @"method" : @"post",
                               @"username" : @"user",
                               @"password" : @"password",
                               @"data" : @{
                                       @"cmd" : @"authenticate",
                                       @"Login" : @"Log In"
                                       }
                               },
                       @"ZJUWLAN": @{
                               @"url" : @"http://net.zju.edu.cn/cgi-bin/srun_portal",
                               @"logoutUrl" : @"http://net.zju.edu.cn/cgi-bin/srun_portal?action=logout&type=2",
                               @"method" : @"post",
                               @"username" : @"username",
                               @"password" : @"password",
                               @"data" : @{
                                       @"action" : @"login",
                                       @"ac_id" : @"3",
                                       @"is_ldap" : @"1",
                                       @"type" : @"2",
                                       @"local_auth" : @"1"
                                       }
                               }
                       };
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
    _mbHud = [[MBProgressHUD alloc] initWithView:self.view];
    _mbHud.yOffset = [UIScreen mainScreen].bounds.size.height / 2 - 100;
    _mbHud.margin = 8.0;
    _mbHud.mode = MBProgressHUDModeText;
    _mbHud.animationType = MBProgressHUDAnimationFade;
    [self.view addSubview:_mbHud];
    
    [self registerSupportedWiFiSSID];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (status == kWiFiConnectStatusAuthenticateFailed ||
        status == kWiFiConnectStatusLocal ||
        status == kWiFiConnectStatusNeedLogin ||
        status == kWiFiConnectStatusNone ||
        status == kWiFiConnectStatusNotSupported)
        [self networkHandler:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)networkHandler:(NSNotification*)notification
{
    if (status == kWiFiConnectStatusAuthenticating) {
        [authRequest clearDelegatesAndCancel];
        authRequest = nil;
    }
    
    switch (self.reachability.currentReachabilityStatus) {
        case ReachableViaWiFi:
            status = kWiFiConnectStatusConnected;
            break;
        case ReachableViaWWAN:
        {
            if (status == kWiFiConnectStatusChecking)
                return;
            
            status = kWiFiConnectStatusChecking;
            NSURL *url = [NSURL URLWithString:@"http://www.msftncsi.com/ncsi.txt"];//@"http://www.apple.com/library/test/success.html"];
            //118.215.93.15
            self.request = [ASIHTTPRequest requestWithURL:url];
            //[self.request addRequestHeader:@"Host" value:@"www.apple.com"];
            self.request.timeOutSeconds = 8.0;
            self.request.delegate = self;
            [self.request setValidatesSecureCertificate:NO];
            [self.request startAsynchronous];
        }
            break;
        case NotReachable:
            status = kWiFiConnectStatusNone;
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - getter&setter

- (UIBarButtonItem*)logoutItem
{
    if (!_logoutItem) {
        _logoutItem = [[UIBarButtonItem alloc] initWithTitle:@"登出"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(onLogout:)];
    }
    return _logoutItem;
}

#pragma mark - Methods

- (void)onLogout:(id)sender
{
    NSString *logoutURL = [[authConfig objectForKey:[Wifi getSSID]] valueForKey:@"logoutUrl"];
    if (!logoutURL)
        return;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    ASIFormDataRequest *logoutRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://net.zju.edu.cn/cgi-bin/srun_portal"]];
    __block ASIFormDataRequest *r = logoutRequest;
    [logoutRequest setTimeOutSeconds:3.0];
    [logoutRequest setRequestMethod:@"post"];
    [logoutRequest setValidatesSecureCertificate:NO];
    [logoutRequest addPostValue:@"logout" forKey:@"action"];
    [logoutRequest addPostValue:@"2" forKey:@"type"];

    [logoutRequest setCompletionBlock:^{
        if (![r.responseString isEqualToString:@"logout_ok"]) {
            _mbHud.labelText = r.responseString;
            [_mbHud show:YES];
            [_mbHud hide:YES
              afterDelay:2.0];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else
            [self networkHandler:nil];
    }];
    [logoutRequest setFailedBlock:^{
        [self networkHandler:nil];
    }];
    [logoutRequest startAsynchronous];
    manuallyLogout = YES;

}

- (NSArray*)supportedWIFI
{
    return @[@"ZJUWLAN",@"CERNET"];
}

- (void)registerSupportedWiFiSSID
{
    if (CNSetSupportedSSIDs((__bridge CFArrayRef)[self supportedWIFI])) {
        NSLog(@"registed");
    }
    else {
        NSLog(@"not registed");
    }
}

- (void)authIfNeeded
{
    NSString *ssid = [Wifi getSSID];
    if ([[self supportedWIFI] containsObject:ssid]) {
        [self authenticateToWIFI:ssid];
    }
    else {
        status = kWiFiConnectStatusNotSupported;
    }
    [self.tableView reloadData];
}

- (void)kickOut
{
    NSArray *accounts = [Wifi getSavedAccounts];
    NSInteger idx = [Wifi defaultAccountIndex];
    NSDictionary *info = [accounts objectAtIndex:idx];
    
    ASIFormDataRequest *kickOutRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://net.zju.edu.cn/rad_online.php"]];
    __block ASIFormDataRequest *r = kickOutRequest;
    [kickOutRequest setTimeOutSeconds:3.0];
    [kickOutRequest setRequestMethod:@"post"];
    [kickOutRequest setValidatesSecureCertificate:NO];
    [kickOutRequest addPostValue:@"auto_dm" forKey:@"action"];
    [kickOutRequest addPostValue:[info valueForKey:@"username"]
                          forKey:@"username"];
    [kickOutRequest addPostValue:[info valueForKey:@"password"]
                          forKey:@"password"];
    [kickOutRequest setCompletionBlock:^{
        if ([r.responseString isEqualToString:@"ok"])
            [self authIfNeeded];
        else {
            _mbHud.labelText = [NSString stringWithFormat:@"踢除失败:%@",r.responseString];
            [_mbHud show:YES];
            [_mbHud hide:YES
              afterDelay:2.0];
            status = kWiFiConnectStatusAuthenticateFailed;
        }
    }];
    [kickOutRequest setFailedBlock:^{
        [self networkHandler:nil];
    }];
    [kickOutRequest startAsynchronous];
    
    status = kWiFiConnectStatusNeedLogin;
}

- (void)authenticateToWIFI:(NSString *)SSID
{
    if (manuallyLogout) {
        manuallyLogout = NO;
        
        _mbHud.labelText = @"登出成功！";
        [_mbHud show:YES];
        [_mbHud hide:YES
          afterDelay:2.0];
        
        return;
    }
    
    NSArray *accounts = [Wifi getSavedAccounts];
    if (accounts.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                        message:@"您还没有添加帐号哦！"
                                                       delegate:self
                                              cancelButtonTitle:@"现在添加"
                                              otherButtonTitles:@"以后", nil];
        alert.tag = UIAlertViewTagAccountManage;
        [alert show];
        status = kWiFiConnectStatusNeedLogin;
    }
    else {
        status = kWiFiConnectStatusAuthenticating;
        NSInteger idx = [Wifi defaultAccountIndex];
        NSDictionary *info = [accounts objectAtIndex:idx];
        
        NSDictionary *config = [authConfig objectForKey:SSID];
        
        authRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[config valueForKey:@"url"]]];
        authRequest.delegate = self;
        authRequest.timeOutSeconds = 6.f;
        [authRequest setPostFormat:ASIURLEncodedPostFormat];
        [authRequest setValidatesSecureCertificate:NO];
        [authRequest setRequestMethod:[config valueForKey:@"method"]];
        [authRequest setPostValue:[info valueForKey:@"username"] forKey:[config valueForKey:@"username"]];
        [authRequest setPostValue:[info valueForKey:@"password"] forKey:[config valueForKey:@"password"]];
        NSDictionary *data = [config objectForKey:@"data"];
        if ([data isKindOfClass:[NSDictionary class]]) {
            [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [authRequest setPostValue:obj
                                   forKey:key];
            }];
        }
        else
            [authRequest setPostValue:[config valueForKey:@"data"] forKey:@"other"];
        [authRequest startAsynchronous];
        hasTriedAuthenticate = YES;
    }
}

- (void)manageAccounts
{
    WifiAccountViewController *manager = [[WifiAccountViewController alloc] init];
    [self.navigationController pushViewController:manager
                                         animated:YES];
}

#pragma mark - UIAlert Delegate

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case UIAlertViewTagAccountManage:
            if (alertView.cancelButtonIndex == buttonIndex) {
                [self manageAccounts];
            }
            break;
        case UIAlertViewTagKickOut:
            if (alertView.cancelButtonIndex != buttonIndex) {
                [self kickOut];
            }
            break;
        default:
            break;
    }
}

#pragma mark - ASIHTTP Delegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    
}

- (void)request:(ASIHTTPRequest *)request
didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    if (request.responseStatusCode == 302)
        redirected = YES;
}

- (void)authenticationNeededForRequest:(ASIHTTPRequest *)request
{
    
}

- (void)request:(ASIHTTPRequest *)request
willRedirectToURL:(NSURL *)newURL
{
    [request clearDelegatesAndCancel];
    redirected = YES;
    authURL = newURL.path;
    
    status = kWiFiConnectStatusNeedLogin;
    [self authIfNeeded];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    do {
        if (request == authRequest) {
            authRequest = nil;
            NSString *res = request.responseString;
            if ([res rangeOfString:@"help.html"].location != NSNotFound ||
                [res rangeOfString:@"login_ok"].location != NSNotFound) {
                [self networkHandler:nil];
                //status = kWiFiConnectStatusConnected;
                break;
            }
            else if ([res isEqualToString:@"user_tab_error"]) {
                _mbHud.labelText = @"认证程序未启动";
            }
            else if ([res isEqualToString:@"Token error"]) {
                _mbHud.labelText = @"令牌错误，请检查重新认证";
            }
            else if ([res isEqualToString:@"username_error"] ||
                     [res isEqualToString:@"password_error"]) {
                _mbHud.labelText = @"用户名或密码错误";
            }
            else if ([res isEqualToString:@"non_auth_error"]) {
                _mbHud.labelText = @"无须认证，可直接上网";
            }
            else if ([res isEqualToString:@"status_error"]) {
                _mbHud.labelText = @"您已欠费";
            }
            else if ([res isEqualToString:@"available_error"]) {
                _mbHud.labelText = @"已禁用";
            }
            else if ([res isEqualToString:@"ip_exist_error"]) {
                _mbHud.labelText = @"IP尚未下线";
            }
            else if ([res isEqualToString:@"usernum_error"]) {
                _mbHud.labelText = @"总用户数已达上限";
            }
            else if ([res isEqualToString:@"online_num_error"] ||
                     [res rangeOfString:@"您已在线"].location != NSNotFound) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                                message:@"您的帐号已在其他地方登录，需要将其踢下线吗？"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"好", nil];
                alert.tag = UIAlertViewTagKickOut;
                [alert show];
                
                status = kWiFiConnectStatusAuthenticateFailed;
                hasTriedAuthenticate = NO;
                break;
            }
            else if ([res isEqualToString:@"mode_error"]) {
                _mbHud.labelText = @"系统已禁止WEB方式登录";
            }
            else if ([res isEqualToString:@"time_policy_error"]) {
                _mbHud.labelText = @"当前时段不允许连接";
            }
            else if ([res isEqualToString:@"flux_error"]) {
                _mbHud.labelText = @"流量已超支";
            }
            else if ([res isEqualToString:@"minutes_error"]) {
                _mbHud.labelText = @"时长已超支";
            }
            else if ([res isEqualToString:@"ip_error"]) {
                _mbHud.labelText = @"地址不合法";
            }
            else if ([res isEqualToString:@"mac_error"]) {
                _mbHud.labelText = @"MAC地址不合法";
            }
            else if ([res isEqualToString:@"sync_error"]) {
                _mbHud.labelText = @"用户的资料被修改，正在同步";
            }
            else {
                NSArray *arr = [res componentsSeparatedByString:@","];
                if ([[arr objectAtIndex:0] intValue] <= 0)
                    _mbHud.labelText = res;
                else {
                    [self networkHandler:nil];
                    break;
                }
            }
            [_mbHud show:YES];
            [_mbHud hide:YES
              afterDelay:2.0];
            
            status = kWiFiConnectStatusAuthenticateFailed;
            hasTriedAuthenticate = NO;
        }
        else {
            NSString *response = request.responseString;
            if ([response hasPrefix:@"Microsoft"]) {
                status = kWiFiConnectStatusConnected;
                hasTriedAuthenticate = NO;
                self.navigationItem.rightBarButtonItem.enabled = YES;
                
                _mbHud.labelText = @"连接成功！";
                [_mbHud show:YES];
                [_mbHud hide:YES
                  afterDelay:2.0];
            }
            else {
                if (hasTriedAuthenticate) {
                    status = kWiFiConnectStatusAuthenticateFailed;
                    hasTriedAuthenticate = NO;
                }
                else {
                    status = kWiFiConnectStatusNeedLogin;
                    [self authIfNeeded];
                }
            }
        }
    } while (0);
    
    self.request = nil;
    [self.tableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (hasTriedAuthenticate) {
        status = kWiFiConnectStatusAuthenticateFailed;
        hasTriedAuthenticate = NO;
    }
    else {
        status = kWiFiConnectStatusLocal;
        if (manuallyLogout) {
            manuallyLogout = NO;
            _mbHud.labelText = @"登出成功！";
            [_mbHud show:YES];
            [_mbHud hide:YES
              afterDelay:2.0];
            [self.navigationItem setRightBarButtonItem:nil
                                              animated:YES];
        }
        else if ([[Wifi getSSID] isEqualToString:@"CERNET"] &&
            request.error.code == 2 &&
            !hasTriedAuthenticate) {
            status = kWiFiConnectStatusAuthenticating;
            [self authenticateToWIFI:@"CERNET"];
        }
    }
    NSLog(@"%@",request.error);
    self.request = nil;
    [self.tableView reloadData];
}

#pragma mark - UITableView Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else
        return 2;
}

- (NSString*)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if (status != kWiFiConnectStatusNone)
            return [NSString stringWithFormat:@"已连接到 %@",[Wifi getSSID]];
        else
            return @"未连接";
    }
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section
{
    if (section == 0 && status == kWiFiConnectStatusNotSupported) {
        NSArray *supported = [self supportedWIFI];
        return [NSString stringWithFormat:@"目前仅支持%@",[supported componentsJoinedByString:@" "]];
    }
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    cell.accessoryView = nil;
    cell.imageView.image = nil;
    cell.textLabel.text = nil;
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [spinnerView stopAnimating];
                    cell.accessoryView = spinnerView;
                    switch (status) {
                        case kWiFiConnectStatusNone:
                            cell.imageView.image = [UIImage imageNamed:@"wifi-gray.png"];
                            cell.textLabel.text = @"没有连接网络";
                            break;
                        case kWiFiConnectStatusNeedLogin:
                            cell.imageView.image = [UIImage imageNamed:@"wifi-yellow.png"];
                            cell.textLabel.text = @"需要登录";
                            break;
                        case kWiFiConnectStatusConnected:
                            cell.imageView.image = [UIImage imageNamed:@"wifi-blue.png"];
                            cell.textLabel.text = @"已连接";
                            if ([[self supportedWIFI] containsObject:[Wifi getSSID]]) {
                                [self.navigationItem setRightBarButtonItem:self.logoutItem
                                                                  animated:YES];
                            }
                            break;
                        case kWiFiConnectStatusLocal:
                            cell.imageView.image = [UIImage imageNamed:@"wifi-yellow.png"];
                            cell.textLabel.text = @"只能访问局域网";
                            break;
                        case kWiFiConnectStatusChecking:
                            cell.imageView.image = [UIImage imageNamed:@"wifi-yellow.png"];
                            cell.textLabel.text = @"正在检查连接状态...";
                            [spinnerView startAnimating];
                            break;
                        case kWiFiConnectStatusAuthenticating:
                            cell.imageView.image = [UIImage imageNamed:@"wifi-yellow.png"];
                            cell.textLabel.text = @"正在认证...";
                            [spinnerView startAnimating];
                            break;
                        case kWiFiConnectStatusAuthenticateFailed:
                            cell.imageView.image = [UIImage imageNamed:@"wifi-red.png"];
                            cell.accessoryView = nil;
                            cell.textLabel.text = @"认证失败，点击重试或检查帐号";
                            break;
                        case kWiFiConnectStatusNotSupported:
                            cell.imageView.image = [UIImage imageNamed:@"wifi-red.png"];
                            cell.textLabel.text = @"不支持此网络认证";
                            break;
                        default:
                            break;
                    }
                    break;
                    
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"帐号管理";
                    break;
                case 1:
                    cell.textLabel.text = @"帮助";
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    if (status != kWiFiConnectStatusConnected &&
                        status != kWiFiConnectStatusAuthenticating)
                        [self networkHandler:nil];
                    break;
                    
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [self manageAccounts];
                    break;
                case 1:
                {
                    UIViewController *helpController = [[UIViewController alloc] init];
                    helpController.title = @"帮助";
                    UIWebView *webView = [[UIWebView alloc] init];
                    [helpController setView:webView];
                    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index"
                                                         withExtension:@"html"
                                                          subdirectory:@"wifihelp"];
                    [webView loadRequest:[NSURLRequest requestWithURL:url]];
                    [self.navigationController pushViewController:helpController
                                                         animated:YES];
                }
                    break;
                default:
                    break;
            }
        default:
            break;
    }
}

@end
