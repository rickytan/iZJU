//
//  Map.m
//  iZJU
//
//  Created by ricky on 12-10-18.
//
//

#import "Map.h"
#import "TileBackgroundOverlay.h"
#import "TileOverlayBackgroundView.h"
#import "TileOverlay.h"
#import "TileOverlayView.h"
#import "ZipArchive.h"
#import "SVProgressHUD.h"
#import "MBProgressHUD.h"

#define LAST_CAMPUS_KEY     @"LastCampus"


// Import runtime.h to unleash the power of objective C
#import <objc/runtime.h>

// this will hold the old drawLayer:inContext: implementation
static void (*_origDrawLayerInContext)(id, SEL, CALayer*, CGContextRef);

// this will override the drawLayer:inContext: method
static void OverrideDrawLayerInContext(UIView *self, SEL _cmd, CALayer *layer, CGContextRef context)
{
    // uncommenting this next line will still perform the old behavior
    //_origDrawLayerInContext(self, _cmd, layer, context);
    
    // change colors if needed so that you don't have a black background
    layer.backgroundColor = [UIColor darkGrayColor].CGColor;
    
    CGContextSetFillColorWithColor(context, layer.backgroundColor);
    CGContextFillRect(context, layer.bounds);
}

static NSDictionary * Campuses = nil;

enum {
    UIAlertViewStartDownloadMap = 100,
    UIAlertViewOpenGoogle,
    UIAlertViewDownloadingMap,
    UIAlertViewWarningDelete
};

@interface Map ()
+ (void)eraseiOS6maps:(UIView*) mapView;

- (void)reloadCurrentMap;
- (void)startLoadMapInBackground:(NSString*)path;
- (void)updateDynamicPaddedBounds;
- (void)loadMapImage:(NSString*)path;
- (void)startLocatePressed:(id)sender;
- (void)optionPressed:(id)sender;
- (void)deleteCampusMap:(NSString*)campusName;

- (void)startDownloadMapPackage:(NSURL*)downloadURL;
- (void)handlerMapPackageDownloaded:(NSString*)packagePath;
- (void)extractPackage:(NSString*)packagePath;
- (NSURL*)getDownloadURLForCampusMap:(NSString*)campusName;

@end

@implementation Map

+ (void)initialize
{
    Campuses = [NSDictionary dictionaryWithObjectsAndKeys:
                @"紫金港校区",@"zjg",
                @"玉泉校区",@"yq",
                @"西溪校区",@"xx",
                @"华家池校区",@"hjc",
                @"之江校区",@"zj",nil];
}

+(void) eraseiOS6maps:(UIView*) mapView
{
    // -- get rendering layer
    UIView *rootView = [mapView.subviews objectAtIndex:0];
    UIView *vkmapView = [rootView.subviews objectAtIndex:0];
    UIView *vkmapCanvas = [vkmapView.subviews objectAtIndex:0];
    // -- set opacity to 0.0
    [vkmapCanvas.layer setOpacity:0.0];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentCampus = [[NSUserDefaults standardUserDefaults] valueForKey:LAST_CAMPUS_KEY];
        if ([NSString isNullOrEmpty:currentCampus])
            currentCampus = @"yq";
        
        self.title = [NSString stringWithFormat:@"%@详图",[Campuses valueForKey:currentCampus]];
    }
    return self;
}

- (void)dealloc
{
    mapView.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setToolbarHidden:NO];
    
    {
        // set up subclass in runtime..in some entering method
        if (IS_IOS_6) {
            [Map eraseiOS6maps:mapView];
        }
        else {
            UIView * mkMapTileView = [((UIView*) [ ((UIView*)[mapView.subviews objectAtIndex:0]).subviews objectAtIndex:0]).subviews objectAtIndex:0];
            Method  origMethod = class_getInstanceMethod([mkMapTileView class], @selector(drawLayer:inContext:));
            
            _origDrawLayerInContext = (void *)method_getImplementation(origMethod);
            
            if(!class_addMethod([mkMapTileView class], @selector(drawLayer:inContext:), (IMP)OverrideDrawLayerInContext, method_getTypeEncoding(origMethod)))
                method_setImplementation(origMethod, (IMP)OverrideDrawLayerInContext);
        }
    }
    
    MKUserTrackingBarButtonItem *trakingItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:mapView];
    
    UIBarButtonItem *spacing = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    
    UIBarButtonItem *option = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPageCurl
                                                                            target:self
                                                                            action:@selector(optionPressed:)];
    if (IS_IOS_5) {
        [option setBackgroundImage:[UIImage imageNamed:@"UIButtonBarPageCurlDefault.png"]
                          forState:UIControlStateNormal
                        barMetrics:UIBarMetricsDefault];
        [option setBackgroundImage:[UIImage imageNamed:@"UIButtonBarPageCurlSelectedDown.png"]
                          forState:UIControlStateHighlighted
                        barMetrics:UIBarMetricsDefault];
    }
    
    self.toolbarItems = [NSArray arrayWithObjects:trakingItem,spacing,option,nil];
    self.navigationController.toolbar.tintColor = DEFAULT_COLOR_SCHEME;
    /*
     TileBackgroundOverlay *bg = [[TileBackgroundOverlay alloc] init];
     [mapView addOverlay:bg];
     */
    
    [self reloadCurrentMap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)reloadCurrentMap
{
    NSString *mapPath = [[NSString cachePath] stringByAppendingFormat:@"/MapTiles/%@",currentCampus];
    [self startLoadMapInBackground:mapPath];
}

- (void)startLoadMapInBackground:(NSString *)path
{
    [mapView removeOverlays:mapView.overlays];
    
    mapView.hidden = YES;
    [spinnerView startAnimating];
    
    [self performSelectorInBackground:@selector(loadMapImage:)
                           withObject:path];
}

-(void)updateDynamicPaddedBounds
{
    MKMapPoint upperLeft = fullBoundingMapRect.origin;
    double width = fullBoundingMapRect.size.width;
    double height = fullBoundingMapRect.size.height;
    
    MKMapRect mRect = mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint northMapPoint = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMaxY(mRect));
    MKMapPoint southMapPoint = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMinY(mRect));
    
    double xMidDist = abs(eastMapPoint.x -  westMapPoint.x)/2;
    double yMidDist = abs(northMapPoint.y -  southMapPoint.y)/2;
    
    
    upperLeft.x = upperLeft.x + xMidDist;
    upperLeft.y = upperLeft.y + yMidDist;
    
    
    double paddedWidth =  width - (xMidDist*2);
    double paddedHeight = height - (yMidDist*2);
    
    paddedBoundingMapRect= MKMapRectMake(upperLeft.x, upperLeft.y, paddedWidth, paddedHeight);
}

- (void)loadMapImage:(NSString *)path
{
    NSString *tileDirectory = path;
    NSString *mapCoordPath = [path stringByAppendingPathComponent:@"MapCoord.plist"];
    NSDictionary *coordInfo = [NSDictionary dictionaryWithContentsOfFile:mapCoordPath];
    if (!coordInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinnerView stopAnimating];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                            message:[NSString stringWithFormat:@"您没有下载%@的离线地图包",[Campuses valueForKey:currentCampus],nil]
                                                           delegate:self
                                                  cancelButtonTitle:@"现在下载"
                                                  otherButtonTitles:@"以后", nil];
            alert.tag = UIAlertViewStartDownloadMap;
            [alert show];
        });
        return;
    }
    
    MKMapPoint NW = MKMapPointForCoordinate((CLLocationCoordinate2D){[[coordInfo valueForKey:@"North"] doubleValue],[[coordInfo valueForKey:@"West"] doubleValue]});
    MKMapPoint SE = MKMapPointForCoordinate((CLLocationCoordinate2D){[[coordInfo valueForKey:@"South"] doubleValue],[[coordInfo valueForKey:@"East"] doubleValue]});
    
    fullBoundingMapRect = MKMapRectMake(NW.x, NW.y, fabs(SE.x-NW.x), fabs(SE.y-NW.y));
    
    TileOverlay *overlay = [[TileOverlay alloc] initWithTileDirectory:tileDirectory];
    if (!overlay) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinnerView stopAnimating];
        });
        return;
    }
    [mapView addOverlay:overlay];
    
    mapView.hidden = NO;
    
    manuallyChangingMapRect = YES;
    [mapView setVisibleMapRect:fullBoundingMapRect];
    manuallyChangingMapRect = NO;
    
    mapView.userLocation.title = @"我在这里！";
    //[mapView setUserTrackingMode:MKUserTrackingModeFollow
    //                    animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinnerView stopAnimating];
    });
}

#pragma mark - Actions

- (void)startLocatePressed:(id)sender
{
    if (mapView.userLocation.isUpdating)
        return;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [locationManager startUpdatingLocation];
    }
}

- (void)optionPressed:(id)sender
{
    MapOptionViewController *option = [[MapOptionViewController alloc] init];
    option.delegate = self;
    option.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentModalViewController:option
                            animated:YES];
}

- (void)deleteCampusMap:(NSString *)campusName
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *delPath = [[NSString cachePath] stringByAppendingFormat:@"/MapTiles/%@",campusName];
    NSError *error = nil;
    if (![fm removeItemAtPath:delPath
                        error:&error])
        NSLog(@"%@",error);
}

- (void)downloadDidFinish:(ASIHTTPRequest*)request
{
    downloadRequest = nil;
    [downloadAlert dismissWithClickedButtonIndex:downloadAlert.cancelButtonIndex
                                        animated:YES];
    downloadAlert = nil;
    
    BOOL shouldDeleteFile = NO;
    if (request.totalBytesRead > 0)
        shouldDeleteFile = YES;
    switch (request.responseStatusCode) {
        case 404:
        {
            [SVProgressHUD showErrorWithStatus:@"数据包不存在！"];
        }
            break;
        case 200:
        case 201:
        case 202:
        case 203:
        case 204:
        case 205:
        case 206:
            [self handlerMapPackageDownloaded:request.downloadDestinationPath];
            shouldDeleteFile = NO;
            break;
        default:
        {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"服务器%d返回错误！",request.responseStatusCode]];
        }
            break;
    }
    if (shouldDeleteFile) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:request.downloadDestinationPath
                                                   error:&error];
    }
}

- (void)downloadDidFail:(ASIHTTPRequest*)request
{
    downloadRequest = nil;
    [downloadAlert dismissWithClickedButtonIndex:downloadAlert.cancelButtonIndex
                                        animated:YES];
    downloadAlert = nil;
    downloadProgressBar = nil;
    
    [SVProgressHUD showErrorWithStatus:@"下载失败！"];
    NSLog(@"%@",request.error);
}

- (void)setProgress:(float)progress
{
    double downloadRate = 1.0*[ASIHTTPRequest averageBandwidthUsedPerSecond]/1024;
    unsigned long long loaded = downloadRequest.partialDownloadSize + downloadRequest.totalBytesRead;
    unsigned long long total = downloadRequest.partialDownloadSize + downloadRequest.contentLength;
    NSString *downMsg = [NSString stringWithFormat:@"%.02fM / %.02fM(%.02fKB/s)",
                         1.0*loaded/(1024*1024),
                         1.0*total/(1024*1024),
                         downloadRate];
    [downloadAlert setMessage:downMsg];
    downloadProgressBar.progress = progress;
}

- (void)startDownloadMapPackage:(NSURL*)downloadURL
{
    downloadRequest = [ASIHTTPRequest requestWithURL:downloadURL];
    [downloadRequest setValidatesSecureCertificate:NO];
    [downloadRequest addRequestHeader:@"Host"
                                value:@"dl.dropbox.com"];
    NSString *downloadPath = [NSString tmpPath];
    downloadPath = [downloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.map",currentCampus]];
    NSString *tmpDownloadPath = [downloadPath stringByAppendingString:@".download"];
    [downloadRequest setDownloadDestinationPath:downloadPath];
    [downloadRequest setTemporaryFileDownloadPath:tmpDownloadPath];
    [downloadRequest setAllowResumeForFileDownloads:YES];
    [downloadRequest setShouldContinueWhenAppEntersBackground:YES];
    //[downloadRequest setSecondsToCache:<#(NSTimeInterval)#>]
    [downloadRequest setDelegate:self];
    [downloadRequest setDidFinishSelector:@selector(downloadDidFinish:)];
    [downloadRequest setDidFailSelector:@selector(downloadDidFail:)];
    
    downloadAlert = [[UIAlertView alloc] initWithTitle:@"正在下载"
                                               message:@"0.00M / 0.00M(0.00KB/s)"
                                              delegate:self
                                     cancelButtonTitle:@"取消"
                                     otherButtonTitles:nil];
    downloadAlert.tag = UIAlertViewDownloadingMap;
    downloadProgressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 240, 19)];
    downloadProgressBar.autoresizesSubviews = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [downloadAlert addSubview:downloadProgressBar];
    [downloadAlert show];
    downloadProgressBar.center = CGPointMake(CGRectGetMidX(downloadAlert.bounds),
                                             CGRectGetMidY(downloadAlert.bounds));
    [downloadRequest setDownloadProgressDelegate:self];
    
    [downloadRequest startAsynchronous];
}

- (void)handlerMapPackageDownloaded:(NSString*)packagePath
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD setStatus:@"正在处理数据包..."];
    [self performSelectorInBackground:@selector(extractPackage:)
                           withObject:packagePath];
}

- (void)extractPackage:(NSString*)packagePath
{
    NSString *extractTo = [[NSString cachePath] stringByAppendingPathComponent:@"MapTiles"];
    ZipArchive *mapPackage = [[ZipArchive alloc] init];
    if (![mapPackage UnzipOpenFile:packagePath]) {
        [SVProgressHUD showErrorWithStatus:@"无法打开数据包！"];
        [mapPackage UnzipCloseFile];
        return;
    }
    if (![mapPackage UnzipFileTo:extractTo
                       overWrite:YES]) {
        [SVProgressHUD showErrorWithStatus:@"处理过程中发生错误！"];
        [mapPackage UnzipCloseFile];
        return;
    }
    if (![mapPackage UnzipCloseFile]) {
        
    }
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:packagePath
                                               error:&error];
    NSLog(@"%@",error);
    
    [SVProgressHUD showSuccessWithStatus:@"恭喜您，地图已经可用！"];
    [self reloadCurrentMap];
}

- (NSURL*)getDownloadURLForCampusMap:(NSString *)campusName
{
    NSDictionary *boxURL = @{
    @"yq": @"https://174.129.13.72/u/46239535/yq.map",
    @"zjg": @"https://174.129.13.72/u/46239535/zjg.map"
    };
    //@"http://dl.dropbox.com/u/46239535/yq.map";
    //yq: @"https://www.box.com/index.php?rm=box_download_shared_file&shared_name=f548493bb49f00f595db&file_id=f_4093756249&rss=1"
    // zjg: @"https://www.box.com/index.php?rm=box_download_shared_file&shared_name=f548493bb49f00f595db&file_id=f_4114930337&rss=1"
    NSString *urlStr = [boxURL valueForKey:campusName];
    
    return [NSURL URLWithString:urlStr];
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [mapView setCenterCoordinate:newLocation.coordinate];
    if ([mapView showsUserLocation] == NO) {
        [mapView setShowsUserLocation:YES];//when this line is commented, there is no problem
    }
    [mapView setCenterCoordinate:newLocation.coordinate
                        animated:YES];
}

#pragma mark - MKMapView delegate

- (void)mapView:(MKMapView *)_mapView
regionDidChangeAnimated:(BOOL)animated
{
    if (manuallyChangingMapRect) //prevents possible infinite recursion when we call setVisibleMapRect below
        return;
    [self updateDynamicPaddedBounds];
    if (paddedBoundingMapRect.size.width > 0 && paddedBoundingMapRect.size.height > 0) {
        MKMapPoint pt =  MKMapPointForCoordinate( mapView.centerCoordinate);
        
        BOOL mapInsidePaddedBoundingRect = MKMapRectContainsPoint(paddedBoundingMapRect, pt);
        
        if (!mapInsidePaddedBoundingRect)
        {
            if (pt.x < MKMapRectGetMinX(paddedBoundingMapRect))
                pt.x = MKMapRectGetMinX(paddedBoundingMapRect);
            else if (pt.x > MKMapRectGetMaxX(paddedBoundingMapRect))
                pt.x = MKMapRectGetMaxX(paddedBoundingMapRect);
            if (pt.y < MKMapRectGetMinY(paddedBoundingMapRect))
                pt.y = MKMapRectGetMinY(paddedBoundingMapRect);
            else if (pt.y > MKMapRectGetMaxY(paddedBoundingMapRect))
                pt.y = MKMapRectGetMaxY(paddedBoundingMapRect);
            // Overlay is no longer visible in the map view.
            // Reset to last "good" map rect...
            manuallyChangingMapRect = YES;
            [mapView setCenterCoordinate:MKCoordinateForMapPoint(pt)
                                animated:YES];
            manuallyChangingMapRect = NO;
        }
    }
    else {
        MKMapPoint pt =  MKMapPointForCoordinate( mapView.centerCoordinate);
        
        BOOL mapCenterInsideFullBoundingRect = MKMapRectContainsPoint(fullBoundingMapRect, pt);
        BOOL mapContainsOverlay = MKMapRectContainsRect(mapView.visibleMapRect,fullBoundingMapRect);
        
        if (!mapCenterInsideFullBoundingRect) {
            if (pt.x < MKMapRectGetMinX(fullBoundingMapRect))
                pt.x = MKMapRectGetMinX(fullBoundingMapRect);
            else if (pt.x > MKMapRectGetMaxX(fullBoundingMapRect))
                pt.x = MKMapRectGetMaxX(fullBoundingMapRect);
            if (pt.y < MKMapRectGetMinY(fullBoundingMapRect))
                pt.y = MKMapRectGetMinY(fullBoundingMapRect);
            else if (pt.y > MKMapRectGetMaxY(fullBoundingMapRect))
                pt.y = MKMapRectGetMaxY(fullBoundingMapRect);
            // Overlay is no longer visible in the map view.
            // Reset to last "good" map rect...
            manuallyChangingMapRect = YES;
            [mapView setCenterCoordinate:MKCoordinateForMapPoint(pt)
                                animated:YES];
            manuallyChangingMapRect = NO;
        }
        
        if (mapContainsOverlay)
        {
            // The overlay is entirely inside the map view but adjust if user is zoomed out too much...
            double widthRatio = fullBoundingMapRect.size.width / mapView.visibleMapRect.size.width;
            double heightRatio = fullBoundingMapRect.size.height / mapView.visibleMapRect.size.height;
            if ((widthRatio < 0.6) && (heightRatio < 0.6)) //adjust ratios as needed
            {
                manuallyChangingMapRect = YES;
                [mapView setVisibleMapRect:fullBoundingMapRect
                                  animated:YES];
                manuallyChangingMapRect = NO;
            }
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView
            viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[TileBackgroundOverlay class]]) {
        return [[TileOverlayBackgroundView alloc] init];
    }
    else {
        TileOverlayView *view = [[TileOverlayView alloc] initWithOverlay:overlay];
        view.tileAlpha = 1.0;
        return view;
    }
    //  Nerver get here !!!
    return nil;
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
    
}

- (void)mapView:(MKMapView *)_mapView
didChangeUserTrackingMode:(MKUserTrackingMode)mode
       animated:(BOOL)animated
{
    
}

- (void)mapView:(MKMapView *)_mapView
didUpdateUserLocation:(MKUserLocation *)userLocation
{
    return;
    // 此时的位置还不是最终位置，貌似，所以不太准
    CLLocationCoordinate2D location = userLocation.location.coordinate;
    MKMapRect boundingRect = ((TileOverlay*)mapView.overlays.lastObject).boundingMapRect;
    if (!MKMapRectContainsPoint(boundingRect, MKMapPointForCoordinate(location))) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您好像不在校园内哦。。。"
                                                        message:@"是否打开地图程序以显示您的位置？"
                                                       delegate:self
                                              cancelButtonTitle:@"不用了"
                                              otherButtonTitles:@"好", nil];
        alert.tag = UIAlertViewOpenGoogle;
        [alert show];
        
        currentLoaction = location;
    }
}

- (void)mapView:(MKMapView *)mapView
didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"%@",error);
    return;
    [[[UIAlertView alloc] initWithTitle:@"无法确定您的位置"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"好"
                      otherButtonTitles:nil] show];
}

#pragma mark - MapOption Delegate

- (void)MapOptionDidSelectCampus:(NSString *)campusName
{
    [self dismissModalViewControllerAnimated:YES];
    
    if ([currentCampus isEqualToString:campusName])
        return;
    
    currentCampus = campusName;
    self.title = [NSString stringWithFormat:@"%@详图",[Campuses valueForKey:currentCampus]];
    
    [[NSUserDefaults standardUserDefaults] setValue:currentCampus
                                             forKey:LAST_CAMPUS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self reloadCurrentMap];
}

- (void)MapOptionDidDeleteCampus:(NSString *)campusName
{
    [self dismissModalViewControllerAnimated:YES];
    
    if ([currentCampus isEqualToString:campusName]) {
        [self deleteCampusMap:campusName];
        [self reloadCurrentMap];
    }
    else {
        [self deleteCampusMap:campusName];
        [SVProgressHUD showSuccessWithStatus:@"已经删除"];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case UIAlertViewStartDownloadMap:
        {
            if (buttonIndex == alertView.cancelButtonIndex) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注意"
                                                                message:@"您的地图会在磁盘空间紧张时由系统自动删除！(地图下载支持断点续传)"
                                                               delegate:self
                                                      cancelButtonTitle:@"知道了"
                                                      otherButtonTitles:nil];
                alert.tag = UIAlertViewWarningDelete;
                [alert show];
            }
        }
            break;
        case UIAlertViewWarningDelete:
        {
            NSURL *url = [self getDownloadURLForCampusMap:currentCampus];
            [self startDownloadMapPackage:url];
        }
            break;
        case UIAlertViewOpenGoogle:
        {
            if (buttonIndex != alertView.cancelButtonIndex) {
                NSString *latlong = [NSString stringWithFormat:@"%.06f,%.06f",
                                     currentLoaction.latitude,
                                     currentLoaction.longitude];
                NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?ll=%@&z=13",
                                 [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        }
            break;
        case UIAlertViewDownloadingMap:
        {
            [downloadRequest clearDelegatesAndCancel];
            downloadRequest = nil;
            downloadAlert = nil;
            downloadProgressBar = nil;
        }
            break;
        default:
            break;
    }
    
}

@end
