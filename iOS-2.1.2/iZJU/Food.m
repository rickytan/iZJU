    //
    //  Food.m
    //  iZJU
    //
    //  Created by 爱机 on 12-8-19.
    //  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
    //

#import <QuartzCore/QuartzCore.h>
#import "Food.h"
#import "PopularFoodViewController.h"
#import "PopularTakeawayViewController.h"


@interface Food ()

@end

@implementation Food
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            // Custom initialization
        self.title = @"美食";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        // Do any additional setup after loading the view from its nib.

    self.navigationItem.backBarButtonItem.tintColor = [UIColor blackColor];
    if (IS_IOS_5) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"foodbar.png"]
                                                      forBarMetrics:UIBarMetricsDefault];
    }
    else {
        [self.navigationController.navigationBar setTintColor:[UIColor blueColor]];
    }
    UIImageView *tablebg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"foodoptablebg.png"]];
    self.tableView.backgroundView = tablebg;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
        // Release any retained subviews of the main view.
        // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions


#pragma mark - UITableView Delegate & Datasource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FoodCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"FoodCell"];
        cell.textLabel.textColor=[UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        bg.contentMode = UIViewContentModeTop;
        bg.image = [UIImage imageNamed:@"cell_separator.png"];
        cell.backgroundView = bg;
        
        UIImageView *indicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 10)];
        indicator.contentMode = UIViewContentModeLeft;
        indicator.image = [UIImage imageNamed:@"indicator_arrow.png"];
        cell.accessoryView = indicator;
    }
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"热门美食";
            cell.imageView.image=[UIImage imageNamed:@"popularfoodicon.png"];
        }
            break;
        case 1:
            cell.textLabel.text = @"热门外卖";
            cell.imageView.image=[UIImage imageNamed:@"populartakeawayicon.png"];
            break;
        case 2:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = nil;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            PopularFoodViewController *popularFood = [[PopularFoodViewController alloc] init];
            [self.navigationController pushViewController:popularFood
                                                 animated:YES];
        }
            break;
        case 1:
        {
            PopularTakeawayViewController *popularTakeaway = [[PopularTakeawayViewController alloc] init];
            [self.navigationController pushViewController:popularTakeaway
                                                 animated:YES];
        }
            break;
        default:
            break;
    }
}
@end
