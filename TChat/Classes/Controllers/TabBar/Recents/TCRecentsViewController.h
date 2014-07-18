//
//  YCRecentsViewController.h
//  YChat
//
//  Created by SWATI KIRVE on 04/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCRecentChatTableViewCell.h"
#import "MBProgressHUD.h"

@interface TCRecentsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,MBProgressHUDDelegate>
{
    TCRecentChatTableViewCell *recentChatCell;
    NSManagedObject *object;
    NSFetchRequest *fetchRequest;
    NSEntityDescription *entityDesc;
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray* chats;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
