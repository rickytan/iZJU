    //
    //  Hotel.m
    //  iZJU
    //
    //  Created by 爱机 on 12-8-19.
    //  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
    //

#import "Hotel.h"
#import "DayHoltel.h"
#import "UsualHotel.h"

@interface Hotel ()

@end

@implementation Hotel

@synthesize tableView = _tableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            // Custom initialization
        self.title = @"住宿";
    }
    return self;
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass(self.class)
                          bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        // Do any additional setup after loading the view from its nib.
    
    if (IS_IOS_5) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"hotelnavbar.png"]
                                                      forBarMetrics:UIBarMetricsDefault];
    }
    else {
        [self.navigationController.navigationBar setTintColor:[UIColor blueColor]];
    }

    if (IS_IPHONE_5) {
        CGRect f = self.tableView.frame;
        f.origin.y += 44.0;
        self.tableView.frame = f;
    }
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

#pragma mark - UITable Delegate & Datasource

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView 
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HotelCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"HotelCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
        bg.contentMode = UIViewContentModeTop;
        bg.image = [UIImage imageNamed:@"cell_separator.png"];
        cell.backgroundView = bg;
        
        UIImageView *indicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 10)];
        indicator.contentMode = UIViewContentModeLeft;
        indicator.image = [UIImage imageNamed:@"indicator_arrow.png"];
        cell.accessoryView = indicator;
    }
    
    switch ([indexPath row]) {
        case 0:
            cell.textLabel.text = @"日租";
            cell.detailTextLabel.text=@"浙大周边日租房信息";
            cell.textLabel.textColor=[UIColor whiteColor];
            cell.imageView.image=[UIImage imageNamed:@"dayhotelicon.png"];
            break;
        case 1:
            cell.textLabel.text = @"住宿";
            cell.detailTextLabel.text=@"这里提供浙大周边宾馆信息";
            cell.textLabel.textColor=[UIColor whiteColor];
            cell.imageView.image=[UIImage imageNamed:@"usualhotelicon.png"];
            break;
        case 2:
            cell.accessoryView = nil;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            DayHoltel *dayHoltel = [[DayHoltel alloc] initWithNibName:@"DayHoltel"
                                                               bundle:nil];
            [self.navigationController pushViewController:dayHoltel
                                                 animated:YES];
        }
            break;
        case 1:
        {
            UsualHotel *usualHotel = [[UsualHotel alloc] initWithNibName:@"UsualHotel"
                                                                  bundle:nil];
            [self.navigationController pushViewController:usualHotel
                                                 animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Action


@end
