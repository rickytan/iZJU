//
//  CC98Cell.m
//  iZJU
//
//  Created by ricky on 13-1-11.
//
//

#import "CC98Cell.h"

@implementation CC98Cell

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

- (void)setFeedItem:(MWFeedItem *)item
{
    self.titleLabel.text = item.title;
    self.authorLabel.text = item.author;
    NSDate *now = [NSDate date];
    NSInteger day,hour,minute;
    NSInteger interval = (NSInteger) [now timeIntervalSinceDate:item.date] + 8*3600;
    day = interval / (24*60*60);
    interval %= 24*60*60;
    hour = interval / (60*60);
    interval %= 60*60;
    minute = interval / 60;
    NSString *dateString = nil;
    if (day)
        dateString = [NSString stringWithFormat:@"%d天%d小时%d分 之前",day,hour,minute];
    else if (hour)
        dateString = [NSString stringWithFormat:@"%d小时%d分 之前",hour,minute];
    else {
        dateString = [NSString stringWithFormat:@"%d分 之前",minute];
    }
    self.authorLabel.text = [NSString stringWithFormat:@"%@ 于%@发表",item.author,dateString];
    self.categoryLabel.text = item.category;
}

@end
