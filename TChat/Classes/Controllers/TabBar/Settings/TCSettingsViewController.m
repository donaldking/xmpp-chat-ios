//
//  YCSettingsViewController.m
//  YChat
//
//  Created by SWATI KIRVE on 05/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import "TCSettingsViewController.h"
#import "TCAppDelegate.h"
#import "TCLoginViewController.h"
#import "TCUserStatusCell.h"

@interface TCSettingsViewController ()

@end

@implementation TCSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutNotificationAction) name:@"logoutNotification" object:nil];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
   // [logoutButton setHidden:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_activityIndicatorView setHidden:YES];
    _userName.text = XAppDelegate.userNickName;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutAction:(UIButton *)sender
{
    [_activityIndicatorView setHidden:NO];
    [_activityIndicatorView startAnimating];
    [XAppDelegate doLogout];
}

-(void)logoutNotificationAction{
    [self restartLogin];
   // [self performSelector:@selector(restartLogin) withObject:nil afterDelay:3];
    
}

-(void)restartLogin{
    //[HUD hide:YES];
    [XAppDelegate prepareXmppChat];
    
    [_activityIndicatorView setHidden:YES];
    [_activityIndicatorView stopAnimating];
    
    TCLoginViewController *loginViewController=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"]; //or the homeController
    XAppDelegate.navController =[[UINavigationController alloc]initWithRootViewController:loginViewController];
    [XAppDelegate.window setRootViewController:XAppDelegate.navController];
    
}


#pragma mark UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *statusCellIdentifier = @"statuscell";
  
    TCUserStatusCell *userStatusCell = (TCUserStatusCell*)[self.tableView dequeueReusableCellWithIdentifier:statusCellIdentifier];
    
    switch (indexPath.row) {
        case 0:
            userStatusCell.titleLbl.text = @"Change Status";
            userStatusCell.userStatus.text = @"ONLINE";
            break;
        case 1:
            userStatusCell.titleLbl.text = @"Sound Notification";
            userStatusCell.userStatus.hidden = YES;
            break;
        case 2:
            userStatusCell.titleLbl.text = @"Show Last Seen Online";
            userStatusCell.userStatus.hidden = YES;
            break;
            
        default:
            break;
    }
    
    return userStatusCell;
 
    
   /* static NSString *myChatCellIdentifier = @"statuscell";
    static NSString *friendChatCellIdentifier = @"friendChatCell";
    
    NSManagedObject *messageObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //  NSString *senderDir = [messageObject valueForKey:@"direction"];
    //  if ([senderDir isEqualToString:@"OUT"])
    
    NSString *senderJid = [messageObject valueForKey:@"sender"];
    if ([senderJid isEqualToString:_currentUser])
    {
        
        // Me
        _myChatCell = (TCMyChatCell*)[self.tableView dequeueReusableCellWithIdentifier:myChatCellIdentifier];
        [_myChatCell setBackgroundColor:[UIColor clearColor]];
        [self configureMyChatCell:_myChatCell atIndexPath:indexPath];
        return _myChatCell;
    }
    else{
        // Friends
        _friendChatCell = (TCFriendChatCell*)[self.tableView dequeueReusableCellWithIdentifier:friendChatCellIdentifier];
        [self configureFriendChatCell:_friendChatCell atIndexPath:indexPath];
        return _friendChatCell;
    }
    return 0;*/
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
