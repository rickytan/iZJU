//
//  TileOverlayBackgroundView.m
//  iZJU
//
//  Created by ricky on 12-10-19.
//
//

#import "TileOverlayBackgroundView.h"

@implementation TileOverlayBackgroundView

- (BOOL)canDrawMapRect:(MKMapRect)mapRect
             zoomScale:(MKZoomScale)zoomScale
{
    return YES;
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{
    CGRect rect = [self rectForMapRect:mapRect];
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextFillRect(context, rect);
}

@end
