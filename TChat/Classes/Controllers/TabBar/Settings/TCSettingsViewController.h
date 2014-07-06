//
//  YCSettingsViewController.h
//  YChat
//
//  Created by SWATI KIRVE on 05/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (IBAction)logoutAction:(UIButton *)sender;

@end
