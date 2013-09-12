//
//  PostCell.m
//  iZJU
//
//  Created by ricky on 12-11-29.
//
//

#import "PostCell.h"

@implementation PostCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    UIMenuItem *up = [[UIMenuItem alloc] initWithTitle:
                      [NSString stringWithFormat:@"%@顶[%@]",
                       self.hasUpped?@"已":@"", self.postUpCount.text]
                                                action:@selector(up:)];
    UIMenuItem *reply = [[UIMenuItem alloc] initWithTitle:@"回复"
                                                   action:@selector(reply:)];
    UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制"
                                                  action:@selector(copyItem:)];
    [[UIMenuController sharedMenuController] setMenuItems:@[up,reply,copy]];
    [[UIMenuController sharedMenuController] setTargetRect:self.frame
                                                    inView:self.superview];
    [[UIMenuController sharedMenuController] setMenuVisible:YES
                                                   animated:YES];
    return [super becomeFirstResponder];;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    BOOL rtnval = [super canPerformAction:action
                               withSender:sender];
    if (action == @selector(reply:))
        rtnval = YES;
    else if (action == @selector(up:))
        rtnval = YES;
    else if (action == @selector(copyItem:))
        rtnval = YES;
    
    return rtnval;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect;
    CGSize size;
    
    self.postUpCount.frame = CGRectMake(262, 8, 36, 14);
    [self.postUpCount sizeToFit];
    rect = self.postUpCount.frame;
    rect.origin.x = MAX(rect.origin.x, CGRectGetMinX(self.postUpBtn.frame) - 2 - CGRectGetWidth(rect));
    self.postUpCount.frame = rect;
    
    self.postTime.frame = CGRectMake(187, 8, 73, 15);
    size = [self.postTime sizeThatFits:self.postTime.bounds.size];
    if (size.width > 73.0) {
        [self.postTime sizeToFit];
        rect = self.postTime.frame;
        rect.origin.x = MIN(rect.origin.x,
                            CGRectGetMinX(self.postUpCount.frame) - 2 - CGRectGetWidth(rect));
    }
    
    
    rect = CGRectMake(7, 30, self.bounds.size.width - 14, self.bounds.size.height);
    size = rect.size;
    if (!refView.hidden) {
        size = [refView sizeThatFits:size];
        rect.size.height = size.height;
        refView.frame = rect;
        rect.origin.y = CGRectGetMaxY(rect);
    }
    
    size = [self.postContent sizeThatFits:rect.size];
    rect.size.height = size.height;
    self.postContent.frame = rect;
}

- (void)setReferenceText:(NSString *)referenceText
{
    if ([NSString isNullOrEmpty:referenceText]) {
        refView.hidden = YES;
        return;
    }
    _referenceText = referenceText;
    
    NSError *error = nil;
    NSString *pattern = [NSString stringWithFormat:@"\\[([^]]+)\\](.*)"];
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                         options:NSRegularExpressionDotMatchesLineSeparators
                                                                           error:&error];
    NSTextCheckingResult *result = [reg firstMatchInString:_referenceText
                                                   options:0
                                                     range:NSMakeRange(0, _referenceText.length)];
    if ([result numberOfRanges] < 3) {
        return;
    }
    
    NSString *userText = [_referenceText substringWithRange:[result rangeAtIndex:1]];
    NSString *contentText = [_referenceText substringWithRange:[result rangeAtIndex:2]];
    
    if (!refView) {
        refView = [[PostRefView alloc] initWithFrame:self.bounds];
        [self addSubview:refView];
    }
    refView.title = userText;
    refView.content = contentText;
    
    refView.hidden = NO;
}

- (CGFloat)desiredHeightInTableView:(UITableView *)tableView
{
    CGRect rect = CGRectMake(7, 30, self.bounds.size.width - 14, self.bounds.size.height);
    CGSize size = rect.size;
    if (!refView.hidden) {
        size = [refView sizeThatFits:size];
        rect.size.height = size.height;
        rect.origin.y = CGRectGetMaxY(rect);
    }
    size = [self.postContent sizeThatFits:rect.size];
    rect.size.height = size.height;
    
    return CGRectGetMaxY(rect) + 7;
}

- (void)prepareForReuse
{
    refView.hidden = YES;
}

- (void)up:(id)sender
{
    if (!self.hasUpped && [self.delegate respondsToSelector:@selector(postCellDidPressUp:)])
        [self.delegate postCellDidPressUp:self];
}

- (void)reply:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(postCellDidPressReply:)])
        [self.delegate postCellDidPressReply:self];
}

- (void)copyItem:(id)sender
{
    [UIPasteboard generalPasteboard].string = self.postContent.text;
}

- (void)setUpped:(BOOL)upped
{
    _upped = upped;
    self.postUpBtn.selected = upped;
}

- (void)increateUpCount
{
    NSNumber *count = [NSNumber numberWithInteger:self.postUpCount.text.intValue+1];
    UILabel *tmpLbl = [[UILabel alloc] initWithFrame:self.postUpCount.bounds];
    tmpLbl.transform = CGAffineTransformMakeTranslation(0, -self.postUpCount.bounds.size.height);
    tmpLbl.text = count.stringValue;
    tmpLbl.font = self.postUpCount.font;
    tmpLbl.textAlignment = self.postUpCount.textAlignment;
    tmpLbl.textColor = self.postUpCount.textColor;
    [self.postUpCount addSubview:tmpLbl];
    [UIView animateWithDuration:0.6
                     animations:^{
                         tmpLbl.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         self.postUpCount.text = tmpLbl.text;
                         [tmpLbl removeFromSuperview];
                     }];
    
    //self.postUpBtn.layer.anchorPoint = CGPointMake(0, 0);
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(15.0/90, 0, 0, 1)];
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(15.0/90, 0, 0, -1)];
    anim.repeatCount = 2.5;
    anim.autoreverses = YES;
    anim.repeatDuration = 1.2;
    [self.postUpBtn.layer addAnimation:anim
                                forKey:@"ShakeThumb"];
    
}

- (NSString*)formatDate:(NSDate*)date
{
    NSString *dateStr = @"秒前";
    NSTimeInterval time = -ceilf([date timeIntervalSinceNow]);
    if (time > 60.0) {
        time /= 60;
        dateStr = @"分钟前";
        if (time > 60.0) {
            time /= 60;
            dateStr = @"小时前";
            if (time > 24.0) {
                time /= 24;
                dateStr = @"天前";
                if (time > 7) {     // 一星期以前的，直接显示时间
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateStyle:NSDateFormatterMediumStyle];
                    [formatter setDateFormat:@"MM月dd日 HH:mm"];
                    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
                    dateStr = [formatter stringFromDate:date];
                    return dateStr;
                }
            }
        }
    }
    dateStr = [NSString stringWithFormat:@"%d%@",(int)time,dateStr];
    return dateStr;
}

- (void)setupCell:(PFObject *)obj upped:(BOOL)upped
{
    
    self.postContent.text = [obj objectForKey:@"content"];
    self.postUser.text = [obj objectForKey:@"userName"];
    self.referenceText = [obj objectForKey:@"referencePost"];
    NSNumber *count = [obj objectForKey:@"upCount"];
    
    self.postUpCount.text = count.stringValue ? count.stringValue:@"0";
    self.postTime.text = [self formatDate:obj.createdAt];
    
    self.upped = upped;
}

@end
