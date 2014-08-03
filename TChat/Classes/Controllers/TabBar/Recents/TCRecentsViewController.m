//
//  YCRecentsViewController.m
//  YChat
//
//  Created by SWATI KIRVE on 04/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import "TCRecentsViewController.h"
#import <CoreData/CoreData.h>
#import "TCAppDelegate.h"
#import "TCConstants.h"
#import "TCUtility.h"
#import "TCChatConversationViewController.h"
#import "TCGroupChatViewController.h"
#import <TUSKXMPPLIB/DDLog.h>
#import <TUSKXMPPLIB/DDTTYLogger.h>


#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface TCRecentsViewController ()

@end

@implementation TCRecentsViewController

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
    
    self.navigationItem.title = @"Recents";
   //  self.navigationBar.topItem.title = @"Recents";
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [self loadData];
    //Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageReceived:) name:kNewMessage  object:nil];
    
}

-(void)newMessageReceived:(NSNotification *)aNotification
{
    DDLogVerbose(@"newMessageReceived in YDChatOverViewController");
    //reload our data
    [self loadData];
}

-(void)loadData
{
    NSString *sender = XAppDelegate.username;
    
    NSMutableDictionary *dicToApi = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%@%@",URL_SCHEME,XAppDelegate.currentHost],@"baseUrl",
                                     [NSString stringWithFormat:@"mobileservices/v1/get_recents.php?sender=%@",sender],@"api",
                                     nil];

    
    [XAppDelegate.ApiMethods doGetRecentChatWithDictionary:dicToApi andCallback:^(id completionResponse) {
        NSLog(@"Completion response: %@",completionResponse);
        
        if ([completionResponse isEqualToString:@"doGetWithDictionary:OK"]) {
            NSLog(@"received success response");
            //TODO
            [self.tableView reloadData];
        }
    }];

    
}



#pragma mark - NSFetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"RecentChat" inManagedObjectContext:XAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"time_stamp" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:5];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:XAppDelegate.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(sender LIKE[c] %@) AND (receiver LIKE[c] %@) OR (sender LIKE[c] %@) AND (receiver LIKE[c] %@)",_buddy,_currentUser,_currentUser,_buddy];
    //[fetchRequest setPredicate:predicate];
    
    _fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error])
    {
        NSLog(@"Error performing fetch: %@", error);
    }
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"Controller did change!");
    
    [self.tableView reloadData];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"Number of sections: %d", [[[self fetchedResultsController] sections] count]);
	return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//return self.chats.count;
    id <NSFetchedResultsSectionInfo> sectionInfo =  [[_fetchedResultsController sections] objectAtIndex:section];
     NSLog(@"Number of Rows in section: %d", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray * nibObjects = [[NSBundle mainBundle] loadNibNamed:@"TCRecentChatTableViewCell" owner:nil options:nil];
    
    for (id obj in nibObjects)
    {
        if ([obj isKindOfClass:[TCRecentChatTableViewCell class]])
        {
            recentChatCell = (TCRecentChatTableViewCell*)obj;
            [recentChatCell setValue:@"recentChatcell" forKey:@"reuseIdentifier"];
    
            
            NSManagedObject *recentObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
            recentChatCell.userJIDLabel.text = [recentObject valueForKey:@"name"];
            recentChatCell.chatMsgLabel.text = [recentObject valueForKey:@"message"];;
            
            
             NSString *displayUsername = [[recentObject valueForKey:@"name"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                  
             NSString *proxyPath = [NSString stringWithFormat:@"path=/people/%@/avatar/128&return=png",displayUsername];
             
             NSString *avatarUrl = [NSString stringWithFormat:@"%@%@/%@%@", @"http://", XAppDelegate.currentHost, @"service/proxy/proxy.yookos.php?", proxyPath];
             [recentChatCell.userImageView setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMAGE]];
            
            NSInteger timestamp = [[recentObject valueForKey:@"time_stamp"] integerValue];
            NSDate *msg_date = [NSDate dateWithTimeIntervalSince1970:timestamp];
            
            NSInteger differenceInDays = [TCUtility numberOfDaysBetDates: [TCUtility formattedDateFor:msg_date]];
            
            if (ABS(differenceInDays) == 0)
            {
                //_myChatCell.date.text = @"Today";
                NSString *ago = [[SORelativeDateTransformer registeredTransformer] transformedValue:msg_date];
                [recentChatCell.timeStampLabel setText:ago];
            }
            else if (ABS(differenceInDays) == 1)
            {
                recentChatCell.timeStampLabel.text = @"Yesterday";
            }
            else
            {
                recentChatCell.timeStampLabel.text = [TCUtility getDateFromString:[TCUtility formattedDateFor:msg_date]];
            }
            break;
        }
    }
    return recentChatCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Delete the conversation.
     /*   Chat* chat = [self.chats objectAtIndex:indexPath.row];
        //this is only the latest chat within a conversation but we need to delete all chats in the conversation
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat"
                                                  inManagedObjectContext:XAppDelegate.managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jidString == %@",chat.jidString];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setEntity:entity];
        NSError *error=nil;
        NSArray *fetchedObjects = [XAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (NSManagedObject *obj in fetchedObjects)
        {
            //Delete this object
            [XAppDelegate.managedObjectContext deleteObject:obj];
        }
        //Save to CoreData
        error = nil;
        if (![XAppDelegate.managedObjectContext save:&error])
        {
            DDLogError(@"error saving");
        }
        //reload the array with data
        [self loadData];*/
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
   // Chat* chat = [self.chats objectAtIndex:indexPath.row];
    
    NSManagedObject *recentObject = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if([[recentObject valueForKey:@"isGroupMessage"] boolValue])
    {
        TCGroupChatViewController *groupChatViewController = [XAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"groupChatView"];
        
        groupChatViewController.chatWithUser = [ [recentObject valueForKey:@"chatWithUser"] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@",XMPP_CONFERENCE_UAT_HOST] withString:@""];
        
        groupChatViewController.hidesBottomBarWhenPushed = YES;
        
        groupChatViewController.navigationItem.title = [recentObject valueForKey:@"name"];
        
        [self.navigationController pushViewController:groupChatViewController animated:YES];

        
    }
    else
    {
    
        XMPPUserCoreDataStorageObject *user = [XAppDelegate.xmppRosterStorage
                                               userForJID:[XMPPJID jidWithString:[recentObject valueForKey:@"chatWithUser"]]
                                               xmppStream:XAppDelegate.xmppStream
                                               managedObjectContext:XAppDelegate.managedObjectContext_roster];
        

        TCChatConversationViewController *chatCoversationViewController = [XAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"chatConversationView"];
        chatCoversationViewController.chatUserObject =  user;;
        
        chatCoversationViewController.hidesBottomBarWhenPushed = YES;
        
        chatCoversationViewController.navigationItem.title = [recentObject valueForKey:@"name"];
        
        [self.navigationController pushViewController:chatCoversationViewController animated:YES];
    }
    
    
  /*  if (self.conversationVC)
        self.conversationVC = nil;
    Chat* chat = [self.chats objectAtIndex:indexPath.row];
    self.conversationVC = [[YDConversationViewController alloc]init];
    [self.conversationVC showConversationForJIDString:chat.jidString];
    [self.navigationController pushViewController:self.conversationVC animated:YES];*/
    
}
- (UIImage *)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
	if (user.photo != nil)
    {
		return  user.photo;
    }
	else
    {
		NSData *photoData = [[XAppDelegate xmppvCardAvatarModule] photoDataForJID:user.jid];
        
		if (photoData != nil)
			return  [UIImage imageWithData:photoData];
		else
			return  [UIImage imageNamed:@"placeholder_profile"];
    }
}
#pragma mark helper methods
-(int)countNewMessagesForJID:(NSString *)jidString
{
    int ret=0;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat"
                                              inManagedObjectContext:XAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jidString == %@",jidString];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *fetchedObjects = [XAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count]>0)
    {
        for (int i=0; i<[fetchedObjects count]; i++) {
            Chat *thisChat = (Chat *)[fetchedObjects objectAtIndex:i];
            if ([thisChat.isNew  boolValue])
                ret++;
        }
        
    }
    fetchedObjects=nil;
    fetchRequest=nil;
    return ret;
}
-(Chat *)LatestChatRecordForJID:(NSString *)jidString
{
    
    Chat *hist;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat"
                                              inManagedObjectContext:XAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jidString == %@",jidString];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *fetchedObjects = [XAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count]>0)
    {
        hist  = (Chat *)[fetchedObjects objectAtIndex:0];
    }
    fetchedObjects=nil;
    fetchRequest=nil;
    return hist;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
