//
//  AboutViewController.h
//  iZJU
//
//  Created by ricky on 12-12-5.
//
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController
{
    IBOutlet UILabel                * _versionLabel;
}

- (IBAction)onSite:(id)sender;
- (IBAction)onEmail:(id)sender;

@end
