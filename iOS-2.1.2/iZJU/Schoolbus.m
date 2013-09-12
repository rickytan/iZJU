//
//  Schoolbus.m
//  iZJU
//
//  Created by 爱机 on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Schoolbus.h"
#import "ViewController.h"
#import "TSLocateView.h"
#import "ZJUDataServer.h"
#import "SVProgressHUD.h"
#import "SchoolBusSearchResultViewController.h"
#import "SchoolBusSpecifiedBusViewController.h"

@interface Schoolbus (Private)
@property (nonatomic, strong) NSArray *cachedBusInfo;
@property (nonatomic, strong) NSArray *buses;
@end

@implementation Schoolbus
@synthesize cachedBusInfo = _cachedBusInfo;
@synthesize buses = _buses;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"校车";
    }
    return self;
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass(self.class)
                          bundle:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _cachedBusInfo = nil;
    busSelecterView.inputView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    busSelecterView.layer.borderWidth = 2.f;
    busSelecterView.layer.cornerRadius = 6.f;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [pickerCampus cancel:nil];
    pickerCampus = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [rotatorView.layer removeAllAnimations];
    [flipView.layer removeAllAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSArray*)getSearchDataFrom:(NSString*)from
                           to:(NSString*)to
{
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"from == %@ AND to == %@",from,to];
    return [self.cachedBusInfo filteredArrayUsingPredicate:filter];
}

- (NSArray*)getSearchDataWithType:(NSString*)type
{
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"type == %@",type];
    return [self.cachedBusInfo filteredArrayUsingPredicate:filter];
}

- (NSArray*)getBustypes
{
    if (!self.cachedBusInfo)
        return nil;
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:20];
    for (ZJUSchoolBusDataItem *item in self.cachedBusInfo) {
        if (![arr containsObject:item.type])
            [arr addObject:item.type];
    }
    return [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int i1 = [obj1 intValue], i2 = [obj2 intValue];
        if (i1 < i2)
            return NSOrderedAscending;
        else if (i1 == i2)
            return NSOrderedSame;
        else
            return NSOrderedDescending;
    }];
}

- (void)loadResultFrom:(NSString*)from
                    to:(NSString*)to
{
    if ([NSString isNullOrEmpty:from] || [NSString isNullOrEmpty:to])
        return;
    
    NSArray *result = [self getSearchDataFrom:from
                                           to:to];
    
    SchoolBusSearchResultViewController *controller = [[SchoolBusSearchResultViewController alloc] init];
    controller.results = result;
    controller.title = [NSString stringWithFormat:@"从 %@ 到 %@",from,to];
    controller.delegate = self;
    [self.navigationController pushViewController:controller
                                         animated:YES];
}

- (void)swapFromTo:(BOOL)animated
{
    NSString *tmp = [fromButton titleForState:UIControlStateNormal];
    [fromButton setTitle:[toButton titleForState:UIControlStateNormal]
                forState:UIControlStateNormal];
    [toButton setTitle:tmp
              forState:UIControlStateNormal];
    if (animated) {
        CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationRotateFrom:-M_PI
                                                                                     to:0
                                                                               duration:.6
                                                                                 frames:64
                                                                        withTimingBlock:CLEaseOutBounceTimingFunction];
        [rotatorView.layer addAnimation:rotateAnimation
                                 forKey:@"Swap"];
        
        rotateAnimation = [CAKeyframeAnimation animationRotateFrom:M_PI
                                                                to:0
                                                          duration:.6
                                                            frames:64
                                                   withTimingBlock:CLEaseOutBounceTimingFunction];
        [fromButton.layer addAnimation:rotateAnimation
                                forKey:@"Keep"];
        [toButton.layer addAnimation:rotateAnimation
                              forKey:@"Keep"];
    }
}

#pragma mark - UIActionSheet

- (void)actionSheet:(TSLocateView *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    pickerCampus = nil;
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
            [fromButton setTitle:actionSheet.fromCampus
                        forState:UIControlStateNormal];
            [toButton setTitle:actionSheet.toCampus
                      forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - Actions

-(IBAction)fromWhere:(id)sender
{
    pickerCampus = [[TSLocateView alloc] initWithTitle:@"出发地     |     目的地"
                                                            delegate:self];
    [pickerCampus initSelect:fromButton.titleLabel.text
                        with:toButton.titleLabel.text];
    [pickerCampus showInView:self.view.window];
}

-(IBAction)toWhere:(id)sender
{
    [self fromWhere:nil];
}

-(IBAction)changeForFromto:(id)sender
{
    [self swapFromTo:YES];
}

-(IBAction)searchBus:(id)sender
{
    if (isSearchBusType) {
        if ([NSString isNullOrEmpty:busSelecterView.text]) {
            CGPoint center = busSelecterView.center;
            center.x += 24.f;
            TimingBlock block = ^float(float ratio) {
                if (ratio == 0.0f || ratio == 1.0f)
                    return ratio;
                else
                {
                    float p = 0.1f;
                    float s = p / 4.0f;
                    return powf(2.0f, -8.0f*ratio) * sinf((ratio-s)*2*M_PI/p) + 1.0f;
                }
            };
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationPositionFrom:center
                                                                                     to:busSelecterView.center
                                                                               duration:1.2
                                                                                 frames:32
                                                                        withTimingBlock:block];
            [busSelecterView.layer addAnimation:animation
                                         forKey:@"chilling"];
        }
        else {
            SchoolBusSpecifiedBusViewController *controller = [[SchoolBusSpecifiedBusViewController alloc] init];
            controller.title = busSelecterView.text;
            controller.results = [self getSearchDataWithType:busSelecterView.text];
            [self.navigationController pushViewController:controller
                                                 animated:YES];
        }
    }
    else {
        if ([fromButton.titleLabel.text isEqualToString:@"选择"]) {
            [SVProgressHUD showErrorWithStatus:@"请先选择起始点！"];
        }
        else {
            if (self.cachedBusInfo) {
                [self loadResultFrom:fromButton.titleLabel.text
                                  to:toButton.titleLabel.text];
            }
            else {
                ZJUSchoolBusDataRequest *request = [ZJUSchoolBusDataRequest dataRequest];
                
                [[ZJUDataServer sharedServer] executeRequest:request
                                                    delegate:self];
                [SVProgressHUD showWithStatus:@"加载中..."
                                     maskType:SVProgressHUDMaskTypeGradient];
            }
        }
    }
}

- (IBAction)swipeDown:(id)sender
{
    [UIView transitionWithView:flipView
                      duration:0.35
                       options:UIViewAnimationOptionTransitionFlipFromBottom |                               UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        rotatorView.hidden = !isSearchBusType;
                        changeFromTo.hidden = !isSearchBusType;
                        busSelecterView.hidden = isSearchBusType;
                        
                        isSearchBusType = !isSearchBusType;
                    }
                    completion:^(BOOL finished) {
                        [busSelecterView resignFirstResponder];
                    }];
}

- (IBAction)swipeUp:(id)sender
{
    [UIView transitionWithView:flipView
                      duration:0.35
                       options:UIViewAnimationOptionTransitionFlipFromTop |     UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        rotatorView.hidden = !isSearchBusType;
                        changeFromTo.hidden = !isSearchBusType;
                        busSelecterView.hidden = isSearchBusType;
                        
                        isSearchBusType = !isSearchBusType;
                    }
                    completion:^(BOOL finished) {
                        [busSelecterView resignFirstResponder];
                    }];
}

- (IBAction)hideInputView:(id)sender
{
    [busSelecterView resignFirstResponder];
}


#pragma mark - SchoolBusSearchResult Delegate

- (void)SchoolBusSearchResultDidPressReverse:(SchoolBusSearchResultViewController *)resultView
{
    [self swapFromTo:NO];
    NSString *from = fromButton.titleLabel.text;
    NSString *to = toButton.titleLabel.text;
    NSArray *result = [self getSearchDataFrom:from
                                           to:to];
    
    resultView.title = [NSString stringWithFormat:@"从 %@ 到 %@",from,to];
    resultView.results = result;
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!textField.inputView) {
        UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
        picker.showsSelectionIndicator = YES;
        
        if (!self.cachedBusInfo) {
            ZJUSchoolBusDataRequest *request = [ZJUSchoolBusDataRequest dataRequest];
            
            [[ZJUDataServer sharedServer] executeRequest:request
                                                delegate:self];
            [SVProgressHUD showWithStatus:@"加载中..."
                                 maskType:SVProgressHUDMaskTypeGradient];
        }
        picker.dataSource = self;
        picker.delegate = self;
        textField.inputView = picker;
    }
    if ([NSString isNullOrEmpty:textField.text] && self.cachedBusInfo) {
        _buses = [self getBustypes];
        @try {
            textField.text = [_buses objectAtIndex:0];
        }
        @catch (NSException *exception) {
            
        }
    }
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    textField.text = nil;
    return NO;
}

#pragma mark - UIPickerView Datasource& Delegate

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (self.buses)
        return self.buses.count;
    return 1;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString*)pickerView:(UIPickerView *)pickerView
            titleForRow:(NSInteger)row
           forComponent:(NSInteger)component
{
    if (self.buses.count > 0) {
        return [self.buses objectAtIndex:row];
    }
    return @"加载中...";
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    busSelecterView.text = [self.buses objectAtIndex:row];
}

#pragma mark - ZJUDataRequest delegate

- (void)requestDidFinished:(ZJUDataRequest *)request
                  withData:(id)data
{
    _cachedBusInfo = data;
    if (isSearchBusType) {
        _buses = [self getBustypes];
        [(UIPickerView*)busSelecterView.inputView reloadAllComponents];
        @try {
            busSelecterView.text = [_buses objectAtIndex:0];
        }
        @catch (NSException *exception) {
            
        }
    }
    else {
        [self loadResultFrom:fromButton.titleLabel.text
                          to:toButton.titleLabel.text];
    }
    [SVProgressHUD dismiss];
}

- (void)requestDidFailed:(ZJUDataRequest *)request
               withError:(NSError *)error
{
    NSLog(@"%@",error);
    [SVProgressHUD showErrorWithStatus:@"矮油，貌似失败了...再试试啦"];
}

@end