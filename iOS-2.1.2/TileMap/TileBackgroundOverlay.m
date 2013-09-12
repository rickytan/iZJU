//
//  TileBackgroundOverlay.m
//  iZJU
//
//  Created by ricky on 12-10-19.
//
//

#import "TileBackgroundOverlay.h"

@implementation TileBackgroundOverlay

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(0, 0);
}

- (MKMapRect)boundingMapRect
{
    return MKMapRectWorld;
}
@end
