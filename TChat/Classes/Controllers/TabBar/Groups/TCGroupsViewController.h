//
//  YCGroupsViewController.h
//  YChat
//
//  Created by SWATI KIRVE on 04/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCAppDelegate.h"

@interface TCGroupsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (IBAction) creatGroupBtnClick:(id) sender;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
