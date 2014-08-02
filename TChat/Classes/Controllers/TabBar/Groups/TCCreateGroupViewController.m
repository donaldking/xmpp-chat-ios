//
//  TCCreateGroupViewController.m
//  TChat
//
//  Created by SWATI KIRVE on 24/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import "TCCreateGroupViewController.h"
#import "TCConstants.h"
#import "Room.h"
#import <TUSKXMPPLIB/XMPPRoomHybridStorage.h>
#import <TUSKXMPPLIB/XMPPRoomMemoryStorage.h>

@interface TCCreateGroupViewController ()
{
    __strong id <XMPPRoomStorage> xmppRoomStorage;
}
@property (nonatomic,strong) NSString *currentRoomString;
@property (nonatomic,strong) XMPPRoom* currentRoom;
@property (nonatomic,strong) NSString* groupID;
@property (nonatomic,strong) NSString* groupName;

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

-(void)  viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self loadData];
    
    [_activityIndicatorView setHidden:YES];
    [_activityIndicatorView stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneAction:(UIBarButtonItem *)sender
{
    // [self dismissViewControllerAnimated:YES completion:nil];

  //  [_activityIndicatorView setHidden:YES];
  //  [_activityIndicatorView stopAnimating];
    
    HUD = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
	[self.view addSubview:HUD];
    [HUD setDimBackground:YES];
    [HUD setRemoveFromSuperViewOnHide:YES];
    [HUD setAnimationType:MBProgressHUDAnimationZoom];
    
	HUD.delegate = self;
	HUD.labelText = @"Please wait";
    [HUD show:YES];

    
    [self createGroupID];
    [self createGroupName];
    [self createRoomXmppAPICall];
}

- (IBAction)backAction:(UIBarButtonItem *)sender
{
      [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)createRoomCustomAPICall
{
    
    NSString *currentUser = [NSString stringWithFormat:@"%@@%@",XAppDelegate.username,XAppDelegate.currentHost];
    
    // Create message to send as dictionary
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _groupID,@"group_id",
                            _groupName,@"group_name",
                            currentUser,@"admin_name",
                            @"",@"password",
                            nil];
    
    // POST TO API, SAVE TO DICTIONARY
    [self apiPostWithDictionary:params];
}

-(void)apiPostWithDictionary:(NSDictionary *)dictionary{
    
    // Build api params
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    [mDic addEntriesFromDictionary:dictionary];
    
    NSMutableDictionary *dicToApi = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%@%@",URL_SCHEME,XAppDelegate.currentHost],@"baseUrl",
                                     @"mobileservices/v1/create_group.php",@"api",
                                     nil];
    
    
    [dicToApi addEntriesFromDictionary:mDic];
    
    [XAppDelegate.ApiMethods doPostWithDictionary:dicToApi andCallback:^(id completionResponse) {
        
        if([completionResponse isEqualToString:@"doPostWithDictionary:OK"])
        {
            NSLog(@"create_group API successful");
        }
        else
        {
            NSLog(@"create_group API failed");
        }
        
    }];
    
}

-(void) addUserCustomAPICall
{
    for (NSIndexPath* indexPath in _selectedIndex) {
        XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSLog(@"XMPPJID jid: %@", [XMPPJID jidWithString:user.jidStr]);
        NSLog(@"user.jidStr: %@", user.jidStr);
        NSLog(@"user.displayName: %@", user.displayName);
        

    
        NSMutableDictionary *dicToApi = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     user.jidStr, @"user_id",
                                     _groupID, @"group_id",
                                     [NSString stringWithFormat:@"%@%@",URL_SCHEME,XAppDelegate.currentHost],@"baseUrl",
                                     @"mobileservices/v1/add_user_to_group.php",@"api",
                                     nil];
    
    
        [XAppDelegate.ApiMethods doPostWithDictionary:dicToApi andCallback:^(id completionResponse) {
        
            if([completionResponse isEqualToString:@"doPostWithDictionary:OK"])
            {
                NSLog(@"create_group API successful");
            }
            else
            {
                NSLog(@"create_group API failed");
            }
        
        }];
    }

    [HUD hide:YES];
    [self dismissViewControllerAnimated:YES completion:nil];

    
}

-(NSString *) myCleanJID
{
    NSString *currentUser = nil;//[NSString stringWithFormat:@"%@@%@",XAppDelegate.username,XAppDelegate.currentHost];
    currentUser = XAppDelegate.username;
    
    return currentUser;
}

-(void) createGroupID
{
    _groupID = nil;
    
    // Create date time
    NSDate *date = [NSDate date];
    int timestamp = [date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%i",timestamp];
    
    NSString *group_id = [NSString stringWithFormat:@"%@_",XAppDelegate.username];
    _groupID = [group_id stringByAppendingString: timeString];

}

-(void) createGroupName
{
    _groupName = nil;
    
    _groupName = [NSString stringWithFormat:@"%@",XAppDelegate.userNickName];
    
    for (NSIndexPath* indexPath in _selectedIndex) {
        XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        _groupName = [_groupName stringByAppendingString:[NSString stringWithFormat:@", %@",user.displayName]];
    }
}


-(void)createRoomXmppAPICall
{
    Room  *newRoom =[NSEntityDescription
                     insertNewObjectForEntityForName:@"Room"
                     inManagedObjectContext:XAppDelegate.managedObjectContext];
   
    self.currentRoomString = _groupName;
    
    newRoom.name =  self.currentRoomString;
    //newRoom.roomJID = [NSString stringWithFormat:@"%@_%@@%@",_groupID,self.currentRoom,XMPP_CONFERENCE_UAT_HOST];//kxmppConferenceServer
    newRoom.roomJID = [NSString stringWithFormat:@"%@@%@",_groupID,XMPP_CONFERENCE_UAT_HOST];
   
    NSError *error = nil;
    if (![XAppDelegate.managedObjectContext save:&error])
    {
        NSLog(@"error saving");
    }
    else
    {
        //Create the room
        //Create a unique name
        //NSString *roomJIDString = [NSString stringWithFormat:@"%@_%@@%@",_groupID,self.currentRoomString,XMPP_CONFERENCE_UAT_HOST];
        
        NSString *roomJIDString = [NSString stringWithFormat:@"%@@%@",_groupID,XMPP_CONFERENCE_UAT_HOST];
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
        [self.currentRoom activate:XAppDelegate.xmppStream];
        
        NSString *kMyNickName = [self myCleanJID];
        
        //joining will create the room
        //We now use a hardcoded nickname of course this should be configurable in some kind of settings option
        [self.currentRoom joinRoomUsingNickname:kMyNickName history:nil];
        
    }
}


#pragma mark delegate methods
-(void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    NSLog(@"joined room");
    //custom API call
    [self createRoomCustomAPICall];
    
}
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    //now we can configure the room
    [self configureThisRoom:sender];
}
-(void)configureThisRoom:(XMPPRoom *)sender
{
    //configure the room
    NSXMLElement *query= [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCOwnerNamespace];
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    
    
    NSXMLElement *root =[NSXMLElement elementWithName:@"field"];
    [root addAttributeWithName:@"type" stringValue:@"hidden"];
    [root addAttributeWithName:@"var"  stringValue:@"FORM_TYPE"];
    NSXMLElement *valField1 = [NSXMLElement elementWithName:@"value" stringValue:@"http://jabber.org/protocol/muc#roomconfig"];
    [root addChild:valField1];
    //[x addChild:field1];
    
    NSXMLElement *loggingfield = [NSXMLElement elementWithName:@"field"];
    [loggingfield addAttributeWithName:@"type" stringValue:@"boolean"];
    [loggingfield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_enable_logging"];
    [loggingfield addAttributeWithName:@"value" stringValue:@"1"];
    //
    NSXMLElement *namefield = [NSXMLElement elementWithName:@"field"];
    [namefield addAttributeWithName:@"type" stringValue:@"text-single"];
    [namefield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomname"];
    [namefield addAttributeWithName:@"value" stringValue:self.currentRoomString];
    
    //
    NSXMLElement *subjectField = [NSXMLElement elementWithName:@"field"];
    [subjectField addAttributeWithName:@"type" stringValue:@"boolean"];
    [subjectField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_changesubject"];
    [subjectField addAttributeWithName:@"value" stringValue:@"1"];
    //
    NSXMLElement *membersonlyField = [NSXMLElement elementWithName:@"field"];
    [membersonlyField addAttributeWithName:@"type" stringValue:@"boolean"];
    [membersonlyField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_membersonly"];
    [membersonlyField addAttributeWithName:@"value" stringValue:@"1"];
    //
    NSXMLElement *moderatedfield = [NSXMLElement elementWithName:@"field"];
    [moderatedfield addAttributeWithName:@"type" stringValue:@"boolean"];
    [moderatedfield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_moderatedroom"];
    [moderatedfield addAttributeWithName:@"value" stringValue:@"0"];
    //
    NSXMLElement *persistentroomfield = [NSXMLElement elementWithName:@"field"];
    [persistentroomfield addAttributeWithName:@"type" stringValue:@"boolean"];
    [persistentroomfield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];
    [persistentroomfield addAttributeWithName:@"value" stringValue:@"0"];
    //
    NSXMLElement *publicroomfield = [NSXMLElement elementWithName:@"field"];
    [publicroomfield addAttributeWithName:@"type" stringValue:@"boolean"];
    [publicroomfield addAttributeWithName:@"var" stringValue:@"muc#roomconfig_publicroom"];
    [publicroomfield addAttributeWithName:@"value" stringValue:@"0"];
    //
    NSXMLElement *maxusersField = [NSXMLElement elementWithName:@"field"];
    [maxusersField addAttributeWithName:@"type" stringValue:@"text-single"];
    [maxusersField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_maxusers"];
    [maxusersField addAttributeWithName:@"value" stringValue:@"10"];
    
    NSXMLElement *ownerField = [NSXMLElement elementWithName:@"field"];
    [ownerField addAttributeWithName:@"type" stringValue:@"jid-multi"];
    [ownerField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomowners"];
    
    NSString *currentUserJID = [NSString stringWithFormat:@"%@@%@",XAppDelegate.username,XAppDelegate.currentHost];
    
    [ownerField addAttributeWithName:@"value" stringValue: currentUserJID];
    
    
    [root addChild:loggingfield];
    [root addChild:namefield];
    [root addChild:membersonlyField];
    [root addChild:moderatedfield];
    [root addChild:persistentroomfield];
    [root addChild:publicroomfield];
    [root addChild:maxusersField];
    [root addChild:ownerField];
    [root addChild:subjectField];
    [x addChild:root];
    
    [sender configureRoomUsingOptions:x];
}

-(void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    //update data
   // [self loadData];
    //Invite all your contacts to join
  /*  NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                              inManagedObjectContext:XAppDelegate.managedObjectContext_roster];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSError *error=nil;
    NSArray *fetchedObjects = [XAppDelegate.managedObjectContext_roster executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in fetchedObjects)
    {
        XMPPUserCoreDataStorageObject *user = (XMPPUserCoreDataStorageObject *)obj;
        NSLog(@"XMPPJID jid: %@", [XMPPJID jidWithString:user.jidStr]);
        
        
        for (NSIndexPath* indexPath in _selectedIndex) {
            XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            group_name = [group_name stringByAppendingString:[NSString stringWithFormat:@",%@",user.displayName]];
        }
        
        [self.currentRoom inviteUser: [XMPPJID jidWithString:user.jidStr] withMessage:@"Join this room"];
    }*/
    
    for (NSIndexPath* indexPath in _selectedIndex) {
        XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
         NSLog(@"XMPPJID jid: %@", [XMPPJID jidWithString:user.jidStr]);
         NSLog(@"user.jidStr: %@", user.jidStr);
         NSLog(@"user.displayName: %@", user.displayName);
        
        //[self.currentRoom inviteUser: [XMPPJID jidWithString:user.jidStr] withMessage:@"Join this room"];
        [self.currentRoom inviteUser: [XMPPJID jidWithString:user.jidStr] withMessage:_groupName];
    }
    [self addUserCustomAPICall];
    

}


#pragma mark - NSFetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [XAppDelegate managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
        
        //	NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
        //	NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd2, nil];
        
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:nil
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
        
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"Controller did change!");
    //reload our data
    [self loadData];
    
    [self.tableView reloadData];
    
}

-(void) loadData
{
    if(self.selectedIndex)
        self.selectedIndex = nil;
    
    self.selectedIndex = [[NSMutableArray alloc]init];
    
    
    
    NSManagedObjectContext *moc = [XAppDelegate managedObjectContext_roster];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    
	//	NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd2, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchBatchSize:25];
    
    //just get those friend who are online
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"primaryResource != nil"];
    //fetch distinct only jidString attribute
    [fetchRequest setPredicate:predicate];
    
    
    NSError *error=nil;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in fetchedObjects)
    {
        XMPPUserCoreDataStorageObject *user = (XMPPUserCoreDataStorageObject*) obj;
        
        NSString *presenceTYPE = user.primaryResource.presence.type;
    }
}


#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"Number of sections: %d", [[[self fetchedResultsController] sections] count]);
	return [[[self fetchedResultsController] sections] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	NSInteger numberOfValidRows = 0;
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
        NSLog(@"sectionInfo.numberOfObjects : %d, %@", sectionInfo.numberOfObjects, sectionInfo);
        
        numberOfValidRows = sectionInfo.numberOfObjects;
    }
	
	return numberOfValidRows;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSArray * nibObjects = [[NSBundle mainBundle] loadNibNamed:@"TCFriendsTableViewCell" owner:nil options:nil];
    
    for (id obj in nibObjects)
    {
        if ([obj isKindOfClass:[TCFriendsTableViewCell class]])
        {
            friendsCell = (TCFriendsTableViewCell*)obj;
            [friendsCell setValue:@"friendcell" forKey:@"reuseIdentifier"];
            
            XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
                
            NSString *presenceTYPE = user.primaryResource.presence.type;
            if([presenceTYPE isEqualToString:@"available"])
                friendsCell.userJIDLabel.text = [NSString stringWithFormat:@"%@ %@", user.displayName, @"Online"];
            else
                friendsCell.userJIDLabel.text = [NSString stringWithFormat:@"%@ %@", user.displayName, @"offline"];
            // friendsCell.userJIDLabel.text = user.displayName;
            [self configurePhotoForCell:friendsCell user:user];
            
            
            if([self.selectedIndex containsObject:indexPath])
                friendsCell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                friendsCell.accessoryType = UITableViewCellAccessoryNone;

        
            break;
        }
    }
    return friendsCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSLog(@"user %@", user.jidStr);
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        [self.selectedIndex addObject:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [self.selectedIndex removeObject:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}


-(void)configurePhotoForCell:(TCFriendsTableViewCell*)friendCell user:(XMPPUserCoreDataStorageObject *)user{
    
    //To do...
    NSString *displayUsername = [[user jidStr] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@",XAppDelegate.currentHost] withString:@""];
    NSString *proxyPath = [NSString stringWithFormat:@"path=/people/%@/avatar/128&return=png",displayUsername];
    //  NSString *avatarUrl = [NSString stringWithFormat:@"%@%@/%@%@",URL_SCHEME,XAppDelegate.currentHost,PROXY_SERVICE,proxyPath];
    
    NSString *avatarUrl = [NSString stringWithFormat:@"%@%@/%@%@", @"http://", XAppDelegate.currentHost, @"service/proxy/proxy.yookos.php?", proxyPath];
    
    [friendCell.userImageView setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMAGE]];
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
