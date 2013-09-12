//
//  LectureTableCell.h
//  iZJU
//
//  Created by sheng tan on 12-10-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJUActivityRequest.h"

@interface LectureTableCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *lectureTime;
@property (nonatomic, assign) IBOutlet UILabel *lectureTitle;
@property (nonatomic, assign) IBOutlet UILabel *lecturePlace;

- (void)setInfoItem:(ZJUActivityListItem*)item;

@end
