//
//  Baike.h
//  iZJU
//
//  Created by 爱机 on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJUWikiRequest.h"
#import "ZJUDataServer.h"

@interface Baike : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate,
ZJUDateRequestDelegate
>
{
    NSArray                 * wikiItems;
    NSArray                 * filteredWikiItems;
    NSArray                 * itemsToShow;
    SystemSoundID             soundID;
    ZJUDataRequest          * _request;
}

@property(strong,nonatomic) IBOutlet UITableView *tableView;

@end
