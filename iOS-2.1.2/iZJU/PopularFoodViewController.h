//
//  PopularFoodViewController.h
//  iZJU
//
//  Created by sheng tan on 12-10-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodCategoryViewController.h"
#import "ZJUDataRequest.h"
#import "SVProgressHUD.h"

@interface PopularFoodViewController : UITableViewController
<FoodCategoryDelegate,
UISearchBarDelegate,
ZJUDateRequestDelegate>
{
    UIView                          * sectionHeader;
    NSString                        * currentCategory;
        //FoodCategoryViewController      * foodCategoryController;
    
    NSArray                         * foodProducts;
    NSArray                         * categoriedProducts;
    NSArray                         * filteredProducts;
}

@property (nonatomic, strong) IBOutlet UIBarButtonItem * categoryBtn;

- (IBAction) categoryPressed:(id)sender;

@end
