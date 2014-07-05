//
//  YCSettingsViewController.m
//  YChat
//
//  Created by SWATI KIRVE on 05/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import "YCSettingsViewController.h"
#import "YCAppDelegate.h"
#import "YCLoginViewController.h"

@interface YCSettingsViewController ()

@end

@implementation YCSettingsViewController

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
    
   // [logoutButton setHidden:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_activityIndicatorView setHidden:YES];
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
    [YAppDelegate doLogout];
}

-(void)logoutNotificationAction{
    [self restartLogin];
   // [self performSelector:@selector(restartLogin) withObject:nil afterDelay:3];
    
}

-(void)restartLogin{
    //[HUD hide:YES];
    [YAppDelegate prepareXmppChat];
    
    [_activityIndicatorView setHidden:YES];
    [_activityIndicatorView stopAnimating];
    
    YCLoginViewController *loginViewController=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"]; //or the homeController
    YAppDelegate.navController =[[UINavigationController alloc]initWithRootViewController:loginViewController];
    [YAppDelegate.window setRootViewController:YAppDelegate.navController];
    
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
