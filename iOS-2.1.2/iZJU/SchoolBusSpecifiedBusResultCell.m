//
//  SchoolBusSearchResultCell.m
//  iZJU
//
//  Created by ricky on 12-10-23.
//
//

#import "SchoolBusSpecifiedBusResultCell.h"

@implementation SchoolBusSpecifiedBusResultCell
@synthesize remarkLabel,timeLabel,fromLabel,toLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Methods

- (void)setupInfo:(ZJUSchoolBusDataItem *)item
{
    self.timeLabel.text = item.time;
    self.fromLabel.text = item.from;
    self.toLabel.text = item.to;
    self.remarkLabel.text = item.remark;
}
@end
