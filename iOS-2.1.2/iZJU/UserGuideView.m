//
//  UserGuideView.m
//  iZJU
//
//  Created by ricky on 12-12-5.
//
//

#import "UserGuideView.h"

@implementation UserGuideView
@synthesize delegate = _delegate;

- (id)initWithImages:(NSArray *)images
{
    self = [self initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor darkGrayColor];
        
        count = images.count;
        
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
        scroll.pagingEnabled = YES;
        scroll.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        scroll.delegate = self;
        scroll.bounces = YES;
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.showsVerticalScrollIndicator = NO;
        scroll.contentSize = CGSizeMake(self.bounds.size.width*images.count, self.bounds.size.height);
        
        int idx = 0;
        for (NSString *img in images) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:img]];
            imgView.contentMode = UIViewContentModeScaleToFill;
            
            CGRect f = self.bounds;
            f.origin.x = f.size.width * idx;
            imgView.frame = f;
            
            [scroll addSubview:imgView];
            
            ++idx;
        }
        [self addSubview:scroll];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > self.bounds.size.width * (count-1) + 40.0f) {
        if ([self.delegate respondsToSelector:@selector(UserGuideDidFinish:)])
            [self.delegate UserGuideDidFinish:self];
    }
}

@end
