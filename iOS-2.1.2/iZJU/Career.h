//
//  Career.h
//  iZJU
//
//  Created by ricky on 12-11-8.
//
//

#import <UIKit/UIKit.h>
#import "ZJUCareerRequest.h"
#import "ZJUDataServer.h"

@interface Career : UITableViewController
<ZJUDateRequestDelegate>
{
    NSArray                     * _items;
    
    ZJUCareerRequest            * _request;
}

@end
