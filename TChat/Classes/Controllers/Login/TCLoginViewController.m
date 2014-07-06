//
//  YCLoginViewController.m
//  YChat
//
//  Created by SWATI KIRVE on 04/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import "TCLoginViewController.h"
#import "UITextField+PaddingText.h"
#import "TCTabBarController.h"

#define MIN_PASSWORD_LENGTH 5
#define defaultTopScrollOffset -40

typedef enum ScrollDirection{
    
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
    
}ScrollDirection;

@interface TCLoginViewController ()

@end

@implementation TCLoginViewController

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
    [self prepareCustomViews];
    
    [XAppDelegate setChatConnectionDelegate:self];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [_scrollView setScrollEnabled:NO];
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 100)];
    
    // Set up notification center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyPressObserver) name:UITextFieldTextDidChangeNotification object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [_activityIndicatorView setHidden:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareCustomViews{
    
    for (UIView *subViews in self.view.subviews) {
        if ([subViews isKindOfClass:[UIView class]]) {
            for (UITextField *textField in subViews.subviews) {
                if ([textField isKindOfClass:[UITextField class]]) {
                    [textField setLeftPadding:15];
                    [textField setRightPadding:15];
                }
            }
        }
    }
    
    [_loginButton setEnabled:NO];
    _loginButton.titleLabel.alpha = 0.4;
}



#pragma mark - Keyboard delegate
-(void) keyboardWillShow:(NSNotification *)note{
    
    keyBordHideByScroll = NO;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
}

-(void)keyPressObserver{
    if ([_userNameField.text length] > 0 && [_passwordField.text length] >= MIN_PASSWORD_LENGTH) {
        [_loginButton setEnabled:YES];
        _loginButton.titleLabel.alpha = 1.0;
    }
    else{
        [_loginButton setEnabled:NO];
        _loginButton.titleLabel.alpha = 0.4;
    }

}


-(void)hideKeyboard{
    for (id textField in self.scrollView.subviews) {
        
        if ([textField isKindOfClass:[UITextField class]] && [textField isFirstResponder]) {
            [textField resignFirstResponder];
        }
    }
}

#pragma mark - Text field delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    switch ([textField returnKeyType]) {
        case UIReturnKeyNext:
        {
            if ([_userNameField.text length] >=2 && [_passwordField.text length] == 0) {
                [_passwordField becomeFirstResponder];
            }
        }
            break;
        case UIReturnKeyDone:
        {
            [textField resignFirstResponder];
        }
            break;
        default:
            break;
    }
    
    return YES;
}



-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}


-(void)bumpScrollViewUpABitWithAdditionalHeight:(float)height
{
    [self.scrollView setContentOffset:CGPointMake(0, keyboardBounds.size.height - height) animated:YES];
}




#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int scrollDirection;
    float lastContentOffset = defaultTopScrollOffset;
    if (lastContentOffset > scrollView.contentOffset.y) {
        scrollDirection = ScrollDirectionDown;
        
        // Flag to avoid resetting keyboard to  0,0
        keyBordHideByScroll = YES;
        
        [self hideKeyboard];
    }
    else if (lastContentOffset < scrollView.contentOffset.y)
    {
        scrollDirection = ScrollDirectionUp;
    }
}

- (IBAction)loginAction:(UIButton *)sender
{
    [self hideKeyboard];
    
    [_loginButton setEnabled:NO];
    [_activityIndicatorView setHidden:NO];
    [_activityIndicatorView startAnimating];
   
    NSLog(@"Will send username: %@ and password: %@",_userNameField.text,_passwordField.text);
    [XAppDelegate doLoginForUsername:_userNameField.text andPassword:_passwordField.text
                         andCallback:^(id completionResponse) {
                         }];
    
  //  [YAppDelegate connectForUsername:@"test1" andPasswrod:@"default" andCallBack:^(id completionResponse){
        
 //   }];
    
   // [YAppDelegate connectForUsername];
    
    /*YCTabBarController *tabBarController=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"tabBar"]; //or the homeController
  //  YAppDelegate.navController =[[UINavigationController alloc]initWithRootViewController:tabBarController];
    [YAppDelegate.window setRootViewController:tabBarController];*/
    
    
    
}


-(void)loginSuccessful{
    NSLog(@"[%@], Login successful delegate called", [self class]);
  /*  XAppDelegate.presence = offline;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccessfulNotification" object:nil];*/
    
    [_loginButton setEnabled:YES];
    [_activityIndicatorView setHidden:YES];
    [_activityIndicatorView stopAnimating];
    
    TCTabBarController *tabBarController=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"tabBar"]; //or the homeController
    //  YAppDelegate.navController =[[UINavigationController alloc]initWithRootViewController:tabBarController];
    [XAppDelegate.window setRootViewController:tabBarController];
    
}

-(void)loginUnsuccessful{
    NSLog(@"[%@], Login unsuccessful delegate called",[self class]);
    
    [_loginButton setEnabled:YES];
    [_activityIndicatorView setHidden:YES];
    [_activityIndicatorView stopAnimating];
    
    
  /*  [XAppDelegate teardownStream];
    [XAppDelegate clearObjectsForEntityName:@"CurrentUser"
                     inManagedObjectContext:XAppDelegate.managedObjectContext andCallback:^(id completionResponse) {
                         //
                     }];
    
    [self performSelector:@selector(restartLogin) withObject:nil afterDelay:2.0];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Authentication Error" message:@"I couldn't authenticate your credentials. Please try again"
                                                       delegate:self cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
    [alertView show];
    
    [_password setText:@""];
    [_password becomeFirstResponder];
    [HUD hide:YES];*/
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Authentication Error" message:@"I couldn't authenticate your credentials. Please try again"
                                                       delegate:self cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
    [alertView show];

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
