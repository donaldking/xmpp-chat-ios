//
//  YCGroupsViewController.m
//  YChat
//
//  Created by SWATI KIRVE on 04/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import "TCGroupsViewController.h"
#import "TCCreateGroupViewController.h"
#import "Room.h"

@interface TCGroupsViewController ()
@property (nonatomic,strong) NSString *currentRoomString;
@property (nonatomic,strong) XMPPRoom* currentRoom;
@end

@implementation TCGroupsViewController

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

- (IBAction) creatGroupBtnClick:(id) sender
{
    
    TCCreateGroupViewController *creatGroupController=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"createGroup"]; //or the homeController
    [self presentViewController:creatGroupController animated:YES completion:nil];
    
    /*
    UIStoryboard *storyboard  = [UIStoryboard storyboardWithName:@"addRetailerStoryboardNew" bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    // NSLog(@"Self: %@",[self class]);
    [self presentViewController:vc animated:YES completion:nil];*/
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
/*
-(NSString *) myCleanJID
{
    NSString *currentUser = [NSString stringWithFormat:@"%@@%@",XAppDelegate.username,XAppDelegate.currentHost];
    currentUser = XAppDelegate.username;
    
    return currentUser;
}


-(void)createRoom
{
    Room  *newRoom =[NSEntityDescription
                     insertNewObjectForEntityForName:@"Room"
                     inManagedObjectContext:XAppDelegate.managedObjectContext];
    newRoom.name =  @"SKGroup";//self.currentRoomString;
    newRoom.roomJID = [NSString stringWithFormat:@"%@_%@%@",[self myCleanJID],self.currentRoom,XMPP_CONFERENCE_UAT_HOST];//kxmppConferenceServer
    NSError *error = nil;
    if (![XAppDelegate.managedObjectContext save:&error])
    {
        NSLog(@"error saving");
    }
    else
    {
        //Create the room
        //Create a unique name
        NSString *roomJIDString = [NSString stringWithFormat:@"%@_%@%@",[self myCleanJID],self.currentRoomString,kxmppConferenceServer];
        XMPPJID *roomJID = [XMPPJID jidWithString:roomJIDString];
#if USE_MEMORY_STORAGE
        xmppRoomStorage = [[XMPPRoomMemoryStorage alloc] init];
#elif USE_HYBRID_STORAGE
        xmppRoomStorage = [XMPPRoomHybridStorage sharedInstance];
#endif
        //Clean first
        if (self.currentRoom)
        {
            [self.currentRoom removeDelegate:self delegateQueue:dispatch_get_main_queue()];
            [self.currentRoom deactivate];
            self.currentRoom=nil;
            
        }
        
        self.currentRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomStorage jid:roomJID];
        [self.currentRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self.currentRoom activate:[self xmppStream]];
        
        //joining will create the room
        //We now use a hardcoded nickname of course this should be configurable in some kind of settings option
        [self.currentRoom joinRoomUsingNickname:kMyNickName history:nil];
        
    }
}
*/
@end
