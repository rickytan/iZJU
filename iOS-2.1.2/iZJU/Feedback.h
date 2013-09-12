//
//  Feedback.h
//  iZJU
//
//  Created by ricky on 12-11-8.
//
//

#import <UIKit/UIKit.h>
#import "ZJUDataRequest.h"
#import "ZJUFeedbackPost.h"
#import "ZJUDataServer.h"

@interface Feedback : UIViewController
<ZJUDateRequestDelegate>

{
    IBOutlet UITextView                 * textView;
    IBOutlet UITextField                * textField;
    
    BOOL                                  isEmailValid;
}


@end
