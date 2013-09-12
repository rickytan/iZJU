//
//  Library.h
//  iZJU
//
//  Created by ricky on 12-11-23.
//
//

#import <UIKit/UIKit.h>

@interface Library : UIViewController
<UIWebViewDelegate>
{
    UIActivityIndicatorView             * spinnerView;
    UISegmentedControl                  * segmentView;
}
@end
