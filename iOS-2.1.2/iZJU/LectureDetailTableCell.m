//
//  LectureDetailTableCell.m
//  iZJU
//
//  Created by ricky on 12-11-8.
//
//

#import "LectureDetailTableCell.h"

@implementation LectureDetailTableCell
@synthesize title = _title;
@synthesize content = _content;

- (void)awakeFromNib
{

}

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

@end
