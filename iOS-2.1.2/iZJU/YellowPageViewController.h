//
//  YellowPageViewController.h
//  iZJU
//
//  Created by ricky on 12-12-14.
//
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "Telephone.h"

@interface YellowPageViewCell : UITableViewCell
@property (nonatomic, strong) UIButton *favButton;
@property (nonatomic, assign, getter = isFavorite) BOOL favorite;
@property (nonatomic, strong) PhoneItem *phoneItem;
- (void)sendSMS:(id)sender;
- (void)setPhoneItem:(PhoneItem*)item;
@end

@interface YellowPageViewController : UITableViewController
{
    FMDatabase                  * _database;
}
@property (nonatomic, assign) NSInteger parentID;
@property (nonatomic, strong) NSArray *phoneNumbers;
@end
