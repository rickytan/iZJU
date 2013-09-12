//
//  CC98.h
//  iZJU
//
//  Created by ricky on 13-1-11.
//
//

#import <UIKit/UIKit.h>
#import "MWFeedParser.h"

@interface CC98 : UIViewController
<MWFeedParserDelegate,
UITableViewDataSource,
UITableViewDelegate>
{
    NSMutableArray                      * _top10Items;
    
    MWFeedParser                        * _feedParser;
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) NSMutableArray *top10Items;
@end
