//
//  iZJUSharer.m
//  iZJU
//
//  Created by ricky on 12-11-8.
//
//

#import "iZJUSharer.h"
#import "AppAction.h"
#import "SHK.h"
#import "SHKActionSheet.h"

@implementation iZJUSharer

- (void)launchWithController:(UIViewController *)controller
{
        SHKItem *item = [SHKItem text:@"我正在使用iZJU"];
        SHKActionSheet *actions = [SHKActionSheet actionSheetForItem:item];
        [actions showInView:controller.view];
}
@end
