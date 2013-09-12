//
//  PopularTakeawayViewController.h
//  iZJU
//
//  Created by sheng tan on 12-10-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopularTakeawayTableCell.h"
#import "ZJUDataRequest.h"

@interface PopularTakeawayViewController : UITableViewController
<PopularTakeawayCellDelegate,
ZJUDateRequestDelegate,
UISearchBarDelegate,
UIActionSheetDelegate>
{
    NSString                    * numberToCall;
    
    NSArray                     * takeawayProducts;
    
    NSArray                     * filteredProducts;
}
@end
