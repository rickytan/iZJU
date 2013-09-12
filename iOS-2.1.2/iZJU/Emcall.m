//
//  Emcall.m
//  iZJU
//
//  Created by 爱机 on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Emcall.h"


@interface Emcall ()

@end

@implementation Emcall
@synthesize tableView = _tableView;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"常用电话";
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data"
                                                             ofType:@"json"];
        NSData *tmp = [NSData dataWithContentsOfFile:filePath];
        _phoneNumbers = [[NSJSONSerialization JSONObjectWithData:tmp
                                                         options:NSJSONReadingMutableLeaves
                                                           error:nil] objectForKey:@"dianhua"];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"紧急电话";
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data"
                                                             ofType:@"json"];
        NSData *tmp = [NSData dataWithContentsOfFile:filePath];
        _phoneNumbers = [[NSJSONSerialization JSONObjectWithData:tmp
                                                         options:NSJSONReadingMutableLeaves
                                                           error:nil] objectForKey:@"dianhua"];
    }
    return self;
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

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

#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [[_phoneNumbers objectAtIndex:indexPath.row] valueForKey:@"name"];
    cell.detailTextLabel.text = [[_phoneNumbers objectAtIndex:indexPath.row] valueForKey:@"number"];
//    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    
    return cell;
}

-(float)tableView:(UITableView *)tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView 
numberOfRowsInSection:(NSInteger)section
{
    return _phoneNumbers.count;
}

-(void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    NSString *number = [[_phoneNumbers objectAtIndex:indexPath.row] valueForKey:@"number"];
    [[AppHelper sharedHelper] showCallerSheetWithTitle:@"拨打电话"
                                                number:number];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [AppHelper makeACallTo:actionSheet.title];
    }
}

#pragma mark - Actions



@end
