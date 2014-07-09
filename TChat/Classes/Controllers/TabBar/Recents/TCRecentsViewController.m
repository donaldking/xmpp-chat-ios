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
    if (self.chats)
        self.chats =nil;
    self.chats = [[NSMutableArray alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat"
                                              inManagedObjectContext:XAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //skip Group messages
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isGroupMessage == %@",[NSNumber numberWithBool:NO]];
    //fetch distinct only jidString attribute
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"jidString"]];
    [fetchRequest setFetchBatchSize:50];
    
    NSError *error=nil;
    NSArray *fetchedObjects = [XAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in fetchedObjects)
    {
        NSMutableDictionary *found = (NSMutableDictionary *)obj;
        NSString *jid = [found valueForKey:@"jidString"];
        //only add the latest one
        [self.chats addObject:[self LatestChatRecordForJID:jid]];
    }
    //reload the table view
    [self.tableView reloadData];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	return self.chats.count;
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
    
            Chat* chat = [self.chats objectAtIndex:indexPath.row];
            
            XMPPUserCoreDataStorageObject *user = [XAppDelegate.xmppRosterStorage
                                                   userForJID:[XMPPJID jidWithString:chat.jidString]
                                                   xmppStream:XAppDelegate.xmppStream
                                                   managedObjectContext:XAppDelegate.managedObjectContext_roster];
            
            recentChatCell.userImageView.image = [self configurePhotoForCell:recentChatCell user:user];
            
            
            NSString *userName = [chat.jidString stringByReplacingOccurrencesOfString:@"uat.yookoschat.com" withString:@""];
            userName = [userName stringByReplacingOccurrencesOfString:@"@" withString:@""];
            recentChatCell.userJIDLabel.text = userName;
            
           // NSString *chatMessage = [NSString stringWithFormat:@"%@: %@",[TCUtility dayLabelForMessage:chat.messageDate],chat.messageBody];
         
            NSString *chatMessage = [NSString stringWithFormat:@"%@", chat.messageBody];
            recentChatCell.chatMsgLabel.text = chatMessage;
            
            NSString *timeStamp = [NSString stringWithFormat:@"%@", [TCUtility dayLabelForMessage:chat.messageDate]];
            recentChatCell.timeStampLabel.text = timeStamp;
            
            break;
        }
    }
    return recentChatCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Delete the conversation.
        Chat* chat = [self.chats objectAtIndex:indexPath.row];
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
        [self loadData];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
