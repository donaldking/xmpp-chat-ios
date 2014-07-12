//
//  YCLoginViewController.h
//  YChat
//
//  Created by SWATI KIRVE on 04/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCAppDelegate.h"
#import "TCChatConnectionProtocol.h"

@interface TCLoginViewController : UIViewController <UIScrollViewDelegate,UITextFieldDelegate, TCChatConnectionProtocol>
{
    CGRect keyboardBounds;
    BOOL keyBordHideByScroll;
}

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;


- (IBAction)loginAction:(UIButton *)sender;


@end
