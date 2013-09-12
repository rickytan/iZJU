//
//  FoodCategoryViewController.h
//  iZJU
//
//  Created by sheng tan on 12-10-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FoodCategoryViewController;

@protocol FoodCategoryDelegate <NSObject>
@optional
- (void) FoodCategoryDidSelectCategory:(NSString*)category;

@end

@interface FoodCategoryViewController : UITableViewController
{
    NSMutableArray              * _categories;
}

@property (nonatomic, assign) id<FoodCategoryDelegate> delegate;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, assign) NSString *selectedCategory;

@end
