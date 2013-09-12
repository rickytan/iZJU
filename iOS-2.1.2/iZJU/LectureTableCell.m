//
//  LectureTableCell.m
//  iZJU
//
//  Created by sheng tan on 12-10-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LectureTableCell.h"

@implementation LectureTableCell
@synthesize lectureTime, lecturePlace, lectureTitle;

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

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)copyItem:(id)sender
{
    
}

- (void)shareItem:(id)sender
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    /*
    CGFloat imageViewOffset = CGRectGetMaxX(self.imageView.frame) + 10;
    CGRect frame;
    frame = self.lectureTime.frame;
    frame.origin = CGPointMake(frame.origin.x + imageViewOffset,
                               frame.origin.y);
    self.lectureTime.frame = frame;
    
    frame = self.lectureTitle.frame;
    frame.origin = CGPointMake(frame.origin.x + imageViewOffset,
                               frame.origin.y);
    self.lectureTitle.frame = frame;
    
    frame = self.lecturePlace.frame;
    frame.origin = CGPointMake(frame.origin.x + imageViewOffset,
                               frame.origin.y);
    self.lecturePlace.frame = frame;
     */
}

- (void)setInfoItem:(ZJUActivityListItem *)item
{
    self.lectureTime.text = item.date;
    self.lecturePlace.text = item.place;
    self.lectureTitle.text = item.title;
}

@end
