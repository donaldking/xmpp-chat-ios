//
//  TCGroupChatViewController.m
//  TChat
//
//  Created by SWATI KIRVE on 27/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import "TCGroupChatViewController.h"
#import <CoreData/CoreData.h>
#import "TChatDefintions.h"
#import "TCUtility.h"


static CGFloat padding = 20.0;
static CGFloat horizontalPadding = 20.0;
static CGFloat phoneKeyboardHeight = 216;
static CGFloat phoneKeyboardWidth = 320;
static CGRect keyboardEmoticonRect;


@interface TCGroupChatViewController ()
{
    BOOL isKeyboardShown;
    BOOL emoticonInputViewShown;
}
@end

@implementation TCGroupChatViewController

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
    // Do any additional setup after loading the view.
    [self loadHistory];
    
    keyboardEmoticonRect = CGRectMake(0, 568, phoneKeyboardWidth, phoneKeyboardHeight);
    
    // Set up textfield notification center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    XAppDelegate.activeChatBuddyJidStr = [_chatUserObject jidStr];
    XAppDelegate.chatMessageDelegate = self;
    
    [self.headerTitle setText:[_chatUserObject valueForKey:@"nickname"]];
    [self.headerView setBackgroundColor:[UIColor colorFromHexString:@"#42C0FB"]];
    
    [self fetchItemsFromStore];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //  [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self viewBootstrap];
    [self fetchItemsFromStore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)loadHistory{
    
    HUD = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
	[self.view addSubview:HUD];
    [HUD setDimBackground:YES];
    [HUD setRemoveFromSuperViewOnHide:YES];
    [HUD setAnimationType:MBProgressHUDAnimationZoom];
    
	HUD.delegate = self;
	HUD.labelText = @"Please wait";
    [HUD show:YES];
    
    NSString *sender = XAppDelegate.username;
    NSString *receiver = _chatWithUser;;//[[_chatUserObject jidStr] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@",XAppDelegate.currentHost] withString:@""];
    
    _currentUser = [NSString stringWithFormat:@"%@@%@",XAppDelegate.username,XMPP_UAT_HOST];
    _buddy = [NSString stringWithFormat:@"%@@%@",_chatWithUser,XMPP_CONFERENCE_UAT_HOST];
    //_chatWithUser;//[_chatUserObject jidStr];
    
    NSMutableDictionary *dicToApi = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%@%@",URL_SCHEME,XAppDelegate.currentHost],@"baseUrl",
                                     [NSString stringWithFormat:@"mobileservices/v1/get_message.php?sender=%@&receiver=%@",sender,receiver],@"api",
                                     nil];
    
   // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((receiver LIKE[c] %@) OR (sender LIKE[c] %@) AND (receiver LIKE[c] %@)", _buddy, _currentUser, _currentUser,_buddy];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(receiver LIKE[c] %@)", _buddy];
    
    [XAppDelegate checkIfObjectExistsForEntityName:@"Chat" withPredicate:predicate inManagedObjectContext:XAppDelegate.managedObjectContext andCallback:^(id completionResponse) {
        if ([completionResponse isEqualToString:@"checkIfObjectExistsForEntityName:YES"]) {
   
            [HUD hide:YES];
        }
        else{
            [XAppDelegate.ApiMethods doGetWithDictionary:dicToApi andCallback:^(id completionResponse) {
                //NSLog(@"Completion response: %@",completionResponse);
                
                if ([completionResponse isEqualToString:@"doGetWithDictionary:OK"]) {
                    [HUD hide:YES];
                }
            }];
        }
    }];
    
 /*   NSString *sender = XAppDelegate.username;
    
    NSString *receiver = _chatWithUser;//[[_chatUserObject jidStr] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@",XAppDelegate.currentHost] withString:@""];
    
    _currentUser = [NSString stringWithFormat:@"%@@%@",XAppDelegate.username,XMPP_CONFERENCE_UAT_HOST];
    _buddy = _chatWithUser;
    
    
    NSMutableDictionary *dicToApi = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%@%@",URL_SCHEME,XAppDelegate.currentHost],@"baseUrl",
                                     [NSString stringWithFormat:@"mobileservices/v1/get_message.php?sender=%@&receiver=%@",sender,receiver],@"api",
                                     nil];
    
 
    [XAppDelegate.ApiMethods doGetWithDictionary:dicToApi andCallback:^(id completionResponse) {
                //NSLog(@"Completion response: %@",completionResponse);
                
                if ([completionResponse isEqualToString:@"doGetWithDictionary:OK"]) {
                    [HUD hide:YES];
                }
            }];
            */
}


#pragma mark - UITextView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView{
    // Send xmpp compose stanza
    id <NSFetchedResultsSectionInfo> sectionInfo =  [[_fetchedResultsController sections] objectAtIndex:0];
    [sectionInfo numberOfObjects] >=1 ? [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[sectionInfo numberOfObjects]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES] : nil;
}

-(void)resignTextView
{
	[_textView resignFirstResponder];
}



-(void) keyboardWillShow:(NSNotification *)note{
    
    // get keyboard size and loctaion
	//CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = _textViewContainer.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	_textViewContainer.frame = containerFrame;
    
    // Move tableview up here!
	CGRect frame = self.tableView.frame;
    frame.size.height = frame.size.height - keyboardBounds.size.height;
    self.tableView.frame = frame;
    
	// commit animations
	[UIView commitAnimations];
    [self scrollToBottom];
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    if (emoticonInputViewShown) {
        [_textView setInputView:nil];
        emoticonInputViewShown = NO;
    }
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = _textViewContainer.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	_textViewContainer.frame = containerFrame;
	
    // Move tableview down here!
	CGRect frame = self.tableView.frame;
    frame.size.height = frame.size.height + keyboardBounds.size.height;
    self.tableView.frame = frame;
    
	// commit animations
	[UIView commitAnimations];
    
    [self scrollToBottom];
}

-(void)keyBoardDidShow:(NSNotification *)notification{
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
}


#pragma mark - scrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int scrollDirection;
    float lastContentOffset = 0;
    if (lastContentOffset > scrollView.contentOffset.y) {
        scrollDirection = DOWN;
        
        [self.textView resignFirstResponder];
    }
    else if (lastContentOffset < scrollView.contentOffset.y)
    {
        scrollDirection = UP;
    }
}

-(void)scrollToBottom{
    
    id <NSFetchedResultsSectionInfo> sectionInfo =  [[_fetchedResultsController sections] objectAtIndex:0];
    [sectionInfo numberOfObjects] >=1 ? [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[sectionInfo numberOfObjects]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO] : nil;
    
}


-(void)viewBootstrap{
    
    _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
	_textView.delegate = self;
    _textView.backgroundColor = [UIColor whiteColor];
    
    // Style layer
    _textView.layer.cornerRadius = 4;
    _textView.layer.borderWidth = 1.0;
    _textView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[UIView class]]) {
            for (UIButton *bView in subView.subviews ) {
                [bView.layer setCornerRadius:3.0];
            }
        }
    }
}


#pragma mark - Fetch methods

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Chat" inManagedObjectContext:XAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"message_date" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:5];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:XAppDelegate.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    
  //  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(sender LIKE[c] %@) AND (receiver LIKE[c] %@) OR (sender LIKE[c] %@) AND (receiver LIKE[c] %@)",_buddy,_currentUser,_currentUser,_buddy];
 
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(receiver LIKE[c] %@)", _buddy];
    [fetchRequest setPredicate:predicate];
    
    _fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)fetchItemsFromStore
{
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error])
    {
		// Update to handle the error appropriately.
		//NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    [self.tableView endUpdates];
    id <NSFetchedResultsSectionInfo> sectionInfo =  [[_fetchedResultsController sections] objectAtIndex:0];
    [sectionInfo numberOfObjects] >=1 ? [self scrollToBottom] : nil;
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            //NSLog(@"Insert");
            break;
            
        case NSFetchedResultsChangeDelete:
            // [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //NSLog(@"Delete");
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[indexPath row] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            //NSLog(@"Update");
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    [self scrollToBottom];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


#pragma mark - TableView DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return [[_fetchedResultsController sections] count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    id <NSFetchedResultsSectionInfo> sectionInfo =  [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSManagedObject *messageObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *message = [messageObject valueForKey:@"message"];
    
    CGSize textSize = {268, 10000.0f};
    CGSize size = [message sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:14] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    size.height += padding*2;
    CGFloat height = size.height < 65 ? 65 : size.height;
    return height;
}

-(void)configureMyChatCell:(id)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSManagedObject *messageObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *mMessage =  [messageObject valueForKey:@"message"];
    
    CGSize textSize = {268, 10000.0f};
    CGSize size = [mMessage sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:14]constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    size.height += (padding);
    
    _myChatCell.message.text = [messageObject valueForKey:@"message"];
    [_myChatCell.message setFrame:CGRectMake(ScreenWidth - size.width - padding - horizontalPadding, _myChatCell.message.frame.origin.y, size.width + padding, size.height)];
    [_myChatCell.message.layer setCornerRadius:5.0f];
    
    NSString *dateString = [messageObject valueForKey:@"message_date"];
    int timestamp = [[NSString stringWithFormat:@"%@",dateString] intValue];
    NSDate *msg_date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    
    NSInteger differenceInDays = [TCUtility numberOfDaysBetDates: [TCUtility formattedDateFor:msg_date]];
    
    if (ABS(differenceInDays) == 0)
    {
        //_myChatCell.date.text = @"Today";
        NSString *ago = [[SORelativeDateTransformer registeredTransformer] transformedValue:msg_date];
        [_myChatCell.date setText:ago];
    }
    else if (ABS(differenceInDays) == 1)
    {
        _myChatCell.date.text = @"Yesterday";
    }
    else
    {
        _myChatCell.date.text = [TCUtility getDateFromString:[TCUtility formattedDateFor:msg_date]];
    }
    
    //  NSString *ago = [[SORelativeDateTransformer registeredTransformer] transformedValue:d];
    //  [_myChatCell.date setText:ago];
    //  NSString *timeStamp = [NSString stringWithFormat:@"%@", [TCUtility dayLabelForMessage:[messageObject valueForKey:@"messageDate"]]];
    //  _myChatCell.date.text = timeStamp;
}

-(void)configureFriendChatCell:(id)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSManagedObject *messageObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *fMessage = [messageObject valueForKey:@"message"];
    
    CGSize textSize = {268, 10000.0f};
    CGSize size = [fMessage sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:14]constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    size.height +=(padding);
    
    _friendChatCell.message.text = [messageObject valueForKey:@"message"];
    [_friendChatCell.message setFrame:CGRectMake(horizontalPadding, _friendChatCell.message.frame.origin.y, size.width + padding, size.height)];
    [_friendChatCell.message.layer setCornerRadius:5.0f];
    
    // Date
    NSString *dateString = [messageObject valueForKey:@"message_date"];
    int timestamp = [[NSString stringWithFormat:@"%@",dateString] intValue];
    NSDate *msg_date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    
    NSInteger differenceInDays = [TCUtility numberOfDaysBetDates: [TCUtility formattedDateFor:msg_date]];
    
    if (ABS(differenceInDays) == 0)
    {
        // _friendChatCell.date.text = @"Today";
        NSString *ago = [[SORelativeDateTransformer registeredTransformer] transformedValue:msg_date];
        [_friendChatCell.date setText:ago];
    }
    else if (ABS(differenceInDays) == 1)
    {
        _friendChatCell.date.text = @"Yesterday";
    }
    else
    {
        _friendChatCell.date.text = [TCUtility getDateFromString:[TCUtility formattedDateFor:msg_date]];
    }
    
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *myChatCellIdentifier = @"myChatCell";
    static NSString *friendChatCellIdentifier = @"friendChatCell";
    
    NSManagedObject *messageObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //  NSString *senderDir = [messageObject valueForKey:@"direction"];
    //  if ([senderDir isEqualToString:@"OUT"])
    
    NSString *senderJid = [messageObject valueForKey:@"sender"];
    if ([senderJid isEqualToString:_currentUser])
    {
        
        // Me
        _myChatCell = (TCMyChatCell*)[self.tableView dequeueReusableCellWithIdentifier:myChatCellIdentifier];
        [_myChatCell setBackgroundColor:[UIColor clearColor]];
        [self configureMyChatCell:_myChatCell atIndexPath:indexPath];
        return _myChatCell;
    }
    else{
        // Friends
        _friendChatCell = (TCFriendChatCell*)[self.tableView dequeueReusableCellWithIdentifier:friendChatCellIdentifier];
        [self configureFriendChatCell:_friendChatCell atIndexPath:indexPath];
        return _friendChatCell;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [UIView animateWithDuration:0.36 animations:^{
        cell.alpha = 0.0f;
        cell.alpha = 1.0f;
    }];
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self resignTextView];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - chat message lifecycle
-(IBAction)sendMessageAction:(id)sender
{
    NSString *message = _textView.text;
    if ([[message stringByReplacingOccurrencesOfString:@" " withString:@""] length] >=1) {
#if !(TARGET_IPHONE_SIMULATOR)
        //TODO   [XAppDelegate.sendMessageSound play];
#endif
        // Create date time
        NSDate *date = [NSDate date];
        int timestamp = [date timeIntervalSince1970];
        NSString *dateString = [NSString stringWithFormat:@"%i",timestamp];
        
        // Create message to send as dictionary
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                _currentUser,@"sender",
                                _buddy,@"receiver",
                                message,@"message",
                                @"0",@"status",
                                dateString,@"message_date",
                                nil];
        
        [XAppDelegate sendAndPersistObjectForEntityName:@"Chat" inManagedObjectContext:XAppDelegate.managedObjectContext withDictionary:params andCallback:^(id completionResponse) {
            //
            if ([completionResponse isEqualToString:@"persistObjectForEntityName:OK"]) {
                
                [self fetchItemsFromStore];
            }
        }];
        
        
        // POST TO API, SAVE TO DICTIONARY
        [self apiPostWithDictionary:params];
        
    }
    [self.textView setText:@""];
}

-(void)apiPostWithDictionary:(NSDictionary *)dictionary{
    
    // Build api params
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    [mDic addEntriesFromDictionary:dictionary];
    
    [mDic setValue:[[mDic valueForKey:@"sender"] stringByReplacingOccurrencesOfString:
                    [NSString stringWithFormat:@"@%@",XAppDelegate.currentHost] withString:@""] forKey:@"sender"];
    [mDic setValue:[[mDic valueForKey:@"receiver"] stringByReplacingOccurrencesOfString:
                    [NSString stringWithFormat:@"@%@",XAppDelegate.currentHost] withString:@""] forKey:@"receiver"];
    
    //http://dev.yookoschat.com/mobileservices/v1/store_message.php?sender=zoepraise&receiver=donaldking&message=KINGKING&mid=longguid
    
    NSMutableDictionary *dicToApi = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%@%@",URL_SCHEME,XAppDelegate.currentHost],@"baseUrl",
                                     @"mobileservices/v1/store_message.php",@"api",
                                     [TCUtility GetUUID],@"mid",
                                     nil];
    
    [dicToApi addEntriesFromDictionary:mDic];
    
    [XAppDelegate.ApiMethods doPostWithDictionary:dicToApi andCallback:^(id completionResponse) {
        
    }];
    
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
