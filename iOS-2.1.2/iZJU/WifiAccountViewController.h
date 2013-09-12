//
//  WifiAccountViewController.h
//  iZJU
//
//  Created by ricky on 12-12-20.
//
//

#import <UIKit/UIKit.h>

@interface WifiAccountViewController : UITableViewController <UIAlertViewDelegate>
{
    NSArray                     * accounts;
    NSInteger                     modifingIndex;
}
@end
