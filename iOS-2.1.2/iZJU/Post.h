//
//  Post.h
//  iZJU
//
//  Created by ricky on 12-11-29.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Post : NSObject
{

}

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *articleId;
@property (nonatomic, strong) NSString *referenceText;
@property (nonatomic, strong) NSString *articleType;   // 属于什么信息的贴子,校园信息、就业等

+ (void)getPostCountOfType:(NSString*)postType
                 articleId:(NSString*)aId
                 withBlock:(void(^)(NSInteger count))handler;

- (void)sendWithCompleteBlock:(void(^)(BOOL succeed))handler;
- (void)sendWithCompleteBlockHasPostedObject:(void (^)(BOOL succeed, PFObject* obj))handler;

@end
