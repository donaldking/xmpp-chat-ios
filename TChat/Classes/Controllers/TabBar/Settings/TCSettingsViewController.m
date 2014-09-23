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
    
    [self configureUserProfilePhoto];
    
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

-(void)configureUserProfilePhoto{
    
    //NSString *displayUsername = [[user jidStr] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@",XAppDelegate.currentHost] withString:@""];
    NSString *displayUsername = XAppDelegate.username;
    NSString *proxyPath = [NSString stringWithFormat:@"path=/people/%@/avatar/128&return=png",displayUsername];
    
    NSString *avatarUrl = [NSString stringWithFormat:@"%@%@/%@%@", @"http://", XAppDelegate.currentHost, @"service/proxy/proxy.yookos.php?", proxyPath];
    
    [_userProfileImg setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMAGE]];
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
            userStatusCell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 1:
            userStatusCell.titleLbl.text = @"Sound Notification";
            userStatusCell.userStatus.hidden = YES;
            
            //TODO check flag
            if([XAppDelegate isSettingOnFor:SOUND_SETTING])
                userStatusCell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                userStatusCell.accessoryType = UITableViewCellAccessoryNone;
             
            break;
        case 2:
            userStatusCell.titleLbl.text = @"Show Last Seen Online";
            userStatusCell.userStatus.hidden = YES;
            
            //TODO check flag
            if([XAppDelegate isSettingOnFor:LAST_SEEN_SETTING])
                userStatusCell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                userStatusCell.accessoryType = UITableViewCellAccessoryNone;
            
            break;
            
        default:
            break;
    }
    
    return userStatusCell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    

    // TODO setting option actions on clikc
    switch (indexPath.row) {
        case 0:
            //TODO - Show picker of 2 options onilne and offline
            break;
        case 1:
            
            if (cell.accessoryType == UITableViewCellAccessoryNone) {
                //TO DO - Enable sound notification
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                //TO DO - Disable sound notification
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            [XAppDelegate updateSettingFor:SOUND_SETTING];
            break;
        case 2:
            if (cell.accessoryType == UITableViewCellAccessoryNone) {
                //TO DO - Enable show user online status
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                //TO DO - Disable show user online status
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            [XAppDelegate updateSettingFor:LAST_SEEN_SETTING];
            break;
            
        default:
            break;
    }

    
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
