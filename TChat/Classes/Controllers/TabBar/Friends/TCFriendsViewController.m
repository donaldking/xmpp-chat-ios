//
//  TCFriendsViewController.m
//  TChat
//
//  Created by SWATI KIRVE on 07/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import "TCFriendsViewController.h"
#import "TCFriendsTableViewCell.h"
#import "TCConstants.h"
#import "TCChatConversationViewController.h"

@interface TCFriendsViewController ()

@end

@implementation TCFriendsViewController

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
    
    segmentStatus = SegmentStatus_All;
}

-(void)  viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if(self.onlineFriendsList)
        self.onlineFriendsList =nil;
    
    self.onlineFriendsList = [[NSMutableArray alloc]init];
    
    
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
        [self.onlineFriendsList addObject:user];
    }
}


- (IBAction) statusSegmentedControlChanged:(id)sender
{
	UISegmentedControl* segmentedControl = (UISegmentedControl*)sender;

	switch (segmentedControl.selectedSegmentIndex)
	{
		case 0:
		{
            segmentStatus = SegmentStatus_All;
			break;
		}
		case 1:
		{
            segmentStatus = SegmentStatus_Online;
			break;
		}
	}
    
    [self.tableView reloadData];
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
/*
- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
		int section = [sectionInfo.name intValue];
		switch (section)
		{
            case 0  :
                return @"Online";
                break;
			case 1  :
                return @"Away";
                break;
            case 2  :
                return @"Offline";
                break;
            default:
                return @"Offline";
                break;
		}
	}
	
	return @"";
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	NSInteger numberOfValidRows = 0;
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
        NSLog(@"sectionInfo.numberOfObjects : %d, %@", sectionInfo.numberOfObjects, sectionInfo);
        
        if(segmentStatus == SegmentStatus_All)
           numberOfValidRows = sectionInfo.numberOfObjects;
        else
        {
            NSLog(@"sectionInfo.numberOfObjects: %d", sectionInfo.numberOfObjects);
            numberOfValidRows = _onlineFriendsList.count;
           /* for(int index = 0; index < sectionInfo.numberOfObjects; index++)
            {
                XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:sectionIndex]];
        
                NSString *presenceTYPE = user.primaryResource.presence.type;
                if(segmentStatus == SegmentStatus_Online && [presenceTYPE isEqualToString:@"available"])
                    numberOfValidRows++;
            }*/
        }
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
            
            if(segmentStatus == SegmentStatus_All) {
                XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
                
                NSString *presenceTYPE = user.primaryResource.presence.type;
                if(segmentStatus == SegmentStatus_Online && [presenceTYPE isEqualToString:@"available"])
                    friendsCell.userJIDLabel.text = [NSString stringWithFormat:@"%@ %@", user.displayName, @"Online"];
                else
                    friendsCell.userJIDLabel.text = [NSString stringWithFormat:@"%@ %@", user.displayName, @"offline"];
                // friendsCell.userJIDLabel.text = user.displayName;
                [self configurePhotoForCell:friendsCell user:user];
            }
            else
            {
                XMPPUserCoreDataStorageObject *user = [[self onlineFriendsList] objectAtIndex:indexPath.row];
                
                NSString *presenceTYPE = user.primaryResource.presence.type;
                if([presenceTYPE isEqualToString:@"available"])
                    friendsCell.userJIDLabel.text = [NSString stringWithFormat:@"%@ %@", user.displayName, @"Online"];
                
                [self configurePhotoForCell:friendsCell user:user];

            }
            break;
        }
    }
    return friendsCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSLog(@"user %@", user.jidStr);
    
    TCChatConversationViewController *chatCoversationViewController = [XAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"chatConversationView"];
    chatCoversationViewController.chatUserObject = user;
    
    chatCoversationViewController.hidesBottomBarWhenPushed = YES;
    
    chatCoversationViewController.navigationItem.title = user.displayName;
    
    [self.navigationController pushViewController:chatCoversationViewController animated:YES];
}

-(void)configurePhotoForCell:(TCFriendsTableViewCell*)friendCell user:(XMPPUserCoreDataStorageObject *)user{
    
    // Our xmppRosterStorgae will cache phtots as they arrive from the xmppvCardAcatarModul
    // We only need to ask the avatar module for a photo, if the roster doesn't have it
    
   // [friendCell.userImageView.layer setCornerRadius:20.0f];
   // [friendCell.userImageView.layer setMasksToBounds:YES];
    
   /* if(user.photo != nil)
    {
        friendCell.userImageView.image = user.photo;
    }
    else
    {
        NSData *photoData = [[XAppDelegate xmppvCardAvatarModule] photoDataForJID:user.jid];
        if(photoData != nil)
            friendCell.userImageView.image = [UIImage imageWithData:photoData];
        else
            friendCell.userImageView.image = [UIImage imageNamed:@"placeholder_profile"];
    }*/

    
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
