//
//  PostRefView.m
//  iZJU
//
//  Created by ricky on 12-12-1.
//
//

#import "PostRefView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PostRefView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImageView *bg = [[UIImageView alloc] initWithFrame:self.bounds];
        bg.image = [UIImage imageNamed:@"post_reply.png"];
        bg.contentMode = UIViewContentModeScaleToFill;
        bg.frame = self.bounds;
        bg.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        bg.layer.borderWidth = 1.0f;
        bg.layer.borderColor = (RGB(173.0/255, 199.0/255, 217.0/255)).CGColor;
        [self addSubview:bg];
        
        CGRect rect = CGRectInset(self.bounds, 6, 6);
        rect.size.height = 20;
        titleLabel = [[UILabel alloc] initWithFrame:rect];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        titleLabel.font = [UIFont boldSystemFontOfSize:12];
        titleLabel.textColor = [UIColor blueColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        
        rect = CGRectInset(self.bounds, 6, 6);
        rect.size.height -= 20;
        rect.origin.y += 20;
        contentLabel = [[UILabel alloc] initWithFrame:rect];
        contentLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.numberOfLines = 0;
        [self addSubview:contentLabel];
    }
    return self;
}

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (void)setTitle:(NSString *)title
{
    titleLabel.text = title;
}

- (void)setContent:(NSString *)content
{
    contentLabel.text = content;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size.width -= 6 * 2;
    size = [contentLabel sizeThatFits:size];
    size.height += contentLabel.frame.origin.y + 6;
    size.width += 6 * 2;
    return size;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
