//
//  PostRefView.h
//  iZJU
//
//  Created by ricky on 12-12-1.
//
//

#import <UIKit/UIKit.h>

@interface PostRefView : UIView
{
    UILabel                 * titleLabel;
    UILabel                 * contentLabel;
}

@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) NSString *content;

@end
