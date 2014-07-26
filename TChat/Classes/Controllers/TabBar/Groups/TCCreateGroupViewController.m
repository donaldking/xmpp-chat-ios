//
//  TCCreateGroupViewController.m
//  TChat
//
//  Created by SWATI KIRVE on 24/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import "TCCreateGroupViewController.h"

@interface TCCreateGroupViewController ()

@end

@implementation TCCreateGroupViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneAction:(UIBarButtonItem *)sender
{
      [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backAction:(UIBarButtonItem *)sender
{
      [self dismissViewControllerAnimated:YES completion:nil];
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
