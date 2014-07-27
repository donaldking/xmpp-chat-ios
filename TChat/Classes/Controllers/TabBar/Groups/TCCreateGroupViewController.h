//
//  TCCreateGroupViewController.h
//  TChat
//
//  Created by SWATI KIRVE on 24/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCFriendsTableViewCell.h"
#import "TCAppDelegate.h"
#import "MBProgressHUD.h"

@interface TCCreateGroupViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,NSFetchedResultsControllerDelegate,XMPPStreamDelegate,XMPPMUCDelegate, MBProgressHUDDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    TCFriendsTableViewCell *friendsCell;
    MBProgressHUD *HUD;
}

@property (nonatomic, strong) NSMutableArray* selectedIndex;

- (IBAction)doneAction:(UIBarButtonItem *)sender;
- (IBAction)backAction:(UIBarButtonItem *)sender;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;


@end
