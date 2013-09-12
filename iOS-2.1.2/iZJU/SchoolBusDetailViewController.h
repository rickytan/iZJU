//
//  SchoolBusDetailViewController.h
//  iZJU
//
//  Created by ricky on 12-10-23.
//
//

#import <UIKit/UIKit.h>
#import "ZJUSchoolBusDataRequest.h"

@interface SchoolBusDetailViewController : UITableViewController
@property (nonatomic, strong) ZJUSchoolBusDataItem *item;
@end
