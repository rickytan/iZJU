//
//  ComingSoon.m
//  iZJU
//
//  Created by ricky on 12-11-8.
//
//

#import "ComingSoon.h"
#import "SVProgressHUD.h"

@implementation ComingSoon

- (void)launchWithController:(UIViewController *)controller
{
    [SVProgressHUD showImage:[UIImage imageNamed:@"haha.png"]
                      status:@"熬夜写代码ing，乃们不要捉急哦！"];
}

@end
