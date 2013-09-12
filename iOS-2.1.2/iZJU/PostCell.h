//
//  PostCell.h
//  iZJU
//
//  Created by ricky on 12-11-29.
//
//

#import <UIKit/UIKit.h>
#import "PostRefView.h"
#import <Parse/Parse.h>

@class PostCell;

@protocol PostCellDelegate <NSObject>

- (void)postCellDidPressUp:(PostCell*)cell;
- (void)postCellDidPressReply:(PostCell *)cell;

@end

@interface PostCell : UITableViewCell
{
    PostRefView                 * refView;
}

@property (nonatomic, assign) IBOutlet UILabel *postUser;
@property (nonatomic, assign) IBOutlet UILabel *postTime;
@property (nonatomic, assign) IBOutlet UILabel *postUpCount;
@property (nonatomic, assign) IBOutlet UILabel *postContent;
@property (nonatomic, assign) IBOutlet UIButton *postUpBtn;
@property (nonatomic, strong) NSString *referenceText;
@property (nonatomic, assign, getter = hasUpped) BOOL upped;
@property (nonatomic, assign) IBOutlet id<PostCellDelegate> delegate;

- (void)increateUpCount;
- (CGFloat)desiredHeightInTableView:(UITableView*)tableView;
- (void)setupCell:(PFObject*)obj upped:(BOOL)upped;

@end
