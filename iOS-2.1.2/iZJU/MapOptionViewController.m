//
//  MapOptionViewController.m
//  iZJU
//
//  Created by ricky on 12-10-19.
//
//

#import "MapOptionViewController.h"


enum {
    UIActionSheetSwitchAction = 100,
    UIActionSheetDeleteAction
};

@interface MapOptionViewController ()

@end

@implementation MapOptionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass(self.class)
                          bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImage *bg = [UIImage imageNamed:@"action-blue-button.png"];
    [switchButton setBackgroundImage:[bg resizableImageWithCapInsets:UIEdgeInsetsMake(23, 12, 23, 12)]
                            forState:UIControlStateNormal];
    bg = [UIImage imageNamed:@"action-blue-button-selected.png"];
    [switchButton setBackgroundImage:[bg resizableImageWithCapInsets:UIEdgeInsetsMake(23, 12, 23, 12)]
                            forState:UIControlStateHighlighted];
    
    bg = [UIImage imageNamed:@"action-red-button.png"];
    [deleteButton setBackgroundImage:[bg resizableImageWithCapInsets:UIEdgeInsetsMake(23, 12, 23, 12)]
                            forState:UIControlStateNormal];
    bg = [UIImage imageNamed:@"action-red-button-selected.png"];
    [deleteButton setBackgroundImage:[bg resizableImageWithCapInsets:UIEdgeInsetsMake(23, 12, 23, 12)]
                            forState:UIControlStateHighlighted];
    [self.view layoutIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex
                                       animated:NO];
    _actionSheet = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onSwitchButton:(id)sender
{
    _actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"紫金港",@"玉泉", nil];
    _actionSheet.tag = UIActionSheetSwitchAction;
    [_actionSheet showInView:self.view];
}

- (IBAction)onDeleteButton:(id)sender
{
    _actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"紫金港",@"玉泉", nil];
    _actionSheet.tag = UIActionSheetDeleteAction;
    [_actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _actionSheet = nil;
    
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    NSString *campus = nil;
    switch (buttonIndex) {
        case 0:
            campus = @"zjg";
            break;
        case 1:
            campus = @"yq";
            break;
    }
    switch (actionSheet.tag) {
        case UIActionSheetSwitchAction:
            if ([self.delegate respondsToSelector:@selector(MapOptionDidSelectCampus:)])
                [self.delegate MapOptionDidSelectCampus:campus];
            break;
        case UIActionSheetDeleteAction:
            if ([self.delegate respondsToSelector:@selector(MapOptionDidDeleteCampus:)])
                [self.delegate MapOptionDidDeleteCampus:campus];
        default:
            break;
    }
}

@end
