//
//  MapOptionViewController.h
//  iZJU
//
//  Created by ricky on 12-10-19.
//
//

#import <UIKit/UIKit.h>

@protocol MapOptionDelegate <NSObject>

- (void)MapOptionDidSelectCampus:(NSString*)campusName;
- (void)MapOptionDidDeleteCampus:(NSString*)campusName;

@end

@interface MapOptionViewController : UIViewController
<UIActionSheetDelegate>
{
    IBOutlet UIButton               * switchButton;
    IBOutlet UIButton               * deleteButton;
    
    UIActionSheet                   * _actionSheet;
}
@property (nonatomic, assign) id<MapOptionDelegate> delegate;

- (IBAction)onSwitchButton:(id)sender;
- (IBAction)onDeleteButton:(id)sender;

@end
