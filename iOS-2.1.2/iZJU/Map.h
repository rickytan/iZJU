//
//  Map.h
//  iZJU
//
//  Created by ricky on 12-10-18.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
//#import <ASIHTTPRequest/ASIHTTPRequest.h>
//#import "ASIHTTPRequest.h"
#import <ASIHTTPFramework/ASIHTTPFramework.h>
#import "MapOptionViewController.h"

@interface Map : UIViewController
<MKMapViewDelegate,
UIAlertViewDelegate,
MapOptionDelegate,
CLLocationManagerDelegate>
{
    IBOutlet MKMapView                  * mapView;
    IBOutlet UIActivityIndicatorView    * spinnerView;
    
    CLLocationCoordinate2D                currentLoaction;
    NSString                            * currentCampus;
    CLLocationManager                   * locationManager;

    
    BOOL                                  manuallyChangingMapRect;

    MKMapRect                             paddedBoundingMapRect;
    MKMapRect                             fullBoundingMapRect;
    
    ASIHTTPRequest                      * downloadRequest;
    UIAlertView                         * downloadAlert;
    UIProgressView                      * downloadProgressBar;
}
@end
