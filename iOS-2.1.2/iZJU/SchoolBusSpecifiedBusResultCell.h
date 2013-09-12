//
//  SchoolBusSearchResultCell.h
//  iZJU
//
//  Created by ricky on 12-10-23.
//
//

#import <UIKit/UIKit.h>
#import "ZJUSchoolBusDataRequest.h"

@interface SchoolBusSpecifiedBusResultCell: UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel * timeLabel;
@property (nonatomic, assign) IBOutlet UILabel * fromLabel;
@property (nonatomic, assign) IBOutlet UILabel * toLabel;
@property (nonatomic, assign) IBOutlet UILabel * remarkLabel;

- (void)setupInfo:(ZJUSchoolBusDataItem*)item;

@end
