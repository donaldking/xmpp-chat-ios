//
//  TCFriendsViewController.h
//  TChat
//
//  Created by SWATI KIRVE on 07/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TCAppDelegate.h"
#import "TCFriendsTableViewCell.h"

enum SegmentStatus
{
    SegmentStatus_All,
    SegmentStatus_Online
};


@interface TCFriendsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    TCFriendsTableViewCell *friendsCell;
    enum SegmentStatus segmentStatus;
  /*  XMPPUserCoreDataStorageObject *user;
    NSInteger selectedRowIndex, selectedSectionIndex;
    BOOL selectionMade;*/
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *statusSegment;

- (IBAction) statusSegmentedControlChanged:(id) sender;

/*@property (nonatomic, strong) IBOutlet UIButton *goOnlineButton;
@property (nonatomic, strong) TSKFriendsCell *friendsCell;
@property (nonatomic, strong) TSKChatiPhoneViewController *chatViewController;

- (IBAction)goOnlineAction:(UIButton *)sender;
- (IBAction)menuBarButtonAction:(UIButton *)sender;
*/

@end
