//
//  TCGroupChatViewController.h
//  TChat
//
//  Created by SWATI KIRVE on 27/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCAppDelegate.h"
#import "MBProgressHUD.h"
#import "TCEmoticonViewController.h"
#import "TCMyChatCell.h"
#import "TCFriendChatCell.h"

@interface TCGroupChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,
    UIScrollViewDelegate,NSFetchedResultsControllerDelegate,UITextViewDelegate,TCChatMessageProtocol,
    MBProgressHUDDelegate>
{
    NSManagedObject *object;
    NSFetchRequest *fetchRequest;
    NSEntityDescription *entityDesc;
    CGRect keyboardBounds;
    CGRect keyboardFrameBeginRect;
    MBProgressHUD *HUD;
    
}

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *textViewContainer;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) TCEmoticonViewController *emoticonSubView;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) XMPPUserCoreDataStorageObject *chatUserObject;
@property (nonatomic, strong) NSString *chatWithUser;
@property (nonatomic, strong) TCMyChatCell *myChatCell;
@property (nonatomic, strong) TCFriendChatCell *friendChatCell;
@property (nonatomic, strong) NSString *currentUser;
@property (nonatomic, strong) NSString *buddy;
@property (weak, nonatomic)   IBOutlet UILabel *composingStatusLabel;

-(IBAction)sendMessageAction:(id)sender;
- (IBAction)backAction:(UIButton *)sender;


@end
