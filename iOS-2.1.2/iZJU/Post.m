//
//  Post.m
//  iZJU
//
//  Created by ricky on 12-11-29.
//
//

#import "Post.h"
#import <Parse/Parse.h>
#import "UIDevice+Hardware.h"

@implementation Post

+ (void)getPostCountOfType:(NSString *)postType
               articleId:(NSString *)aId
                 withBlock:(void (^)(NSInteger))handler
{
    PFQuery *query = [PFQuery queryWithClassName:postType];
    [query whereKey:@"articleId" equalTo:aId];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error)
            number = -1;
        handler(number);
    }];
}

- (id)init
{
    if (self = [super init]) {
        UIDevice *device = [UIDevice currentDevice];
        
        _userName = [NSString stringWithFormat:@"iZJU %@党",[device platformString]];
        _referenceText = @"";
    }
    return self;
}

- (void)sendWithCompleteBlock:(void (^)(BOOL))handler
{
    if ([NSString isNullOrEmpty:self.articleType]) {
        handler(NO);
        return;
    }
    PFObject *postObject = [PFObject objectWithClassName:self.articleType];
    [postObject setObject:self.userName
                   forKey:@"userName"];
    [postObject setObject:self.content
                   forKey:@"content"];
    [postObject setObject:self.articleId
                   forKey:@"articleId"];
    [postObject setObject:[NSNumber numberWithInt:0]
                   forKey:@"upCount"];
    [postObject setObject:self.referenceText
                   forKey:@"referencePost"];
    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        handler(succeeded);
    }];
}

- (void)sendWithCompleteBlockHasPostedObject:(void (^)(BOOL, PFObject *))handler
{
    PFObject *postObject = [PFObject objectWithClassName:self.articleType];

    [postObject setObject:self.userName
                   forKey:@"userName"];
    [postObject setObject:self.content
                   forKey:@"content"];
    [postObject setObject:self.articleId
                   forKey:@"articleId"];
    [postObject setObject:[NSNumber numberWithInt:0]
                   forKey:@"upCount"];
    [postObject setObject:self.referenceText
                   forKey:@"referencePost"];
    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        handler(succeeded, postObject);
    }];
}

@end
