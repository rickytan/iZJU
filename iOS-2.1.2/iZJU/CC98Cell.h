//
//  CC98Cell.h
//  iZJU
//
//  Created by ricky on 13-1-11.
//
//

#import <UIKit/UIKit.h>
#import "MWFeedItem.h"

@interface CC98Cell : UITableViewCell
@property (nonatomic, assign) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) IBOutlet UILabel *authorLabel;
@property (nonatomic, assign) IBOutlet UILabel *categoryLabel;
- (void)setFeedItem:(MWFeedItem*)item;
@end
