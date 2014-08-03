//
//  YCSettingsViewController.h
//  YChat
//
//  Created by SWATI KIRVE on 05/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCSettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *userName;
@property (nonatomic, strong) IBOutlet UIImageView *userProfileImg;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (IBAction)logoutAction:(UIButton *)sender;


@end
