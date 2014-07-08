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
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
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
    
    [self.tableView reloadData];
}


#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[[self fetchedResultsController] sections] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

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
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
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
            friendsCell.userJIDLabel.text = user.displayName;
            [self configurePhotoForCell:friendsCell user:user];
            break;
        }
    }
    return friendsCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSLog(@"user %@", user.jidStr);
}

-(void)configurePhotoForCell:(TCFriendsTableViewCell*)friendCell user:(XMPPUserCoreDataStorageObject *)user{
    
    // Our xmppRosterStorgae will cache phtots as they arrive from the xmppvCardAcatarModul
    // We only need to ask the avatar module for a photo, if the roster doesn't have it
    
    [friendCell.userImageView.layer setCornerRadius:20.0f];
    [friendCell.userImageView.layer setMasksToBounds:YES];
    
    if(user.photo != nil)
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
    }

    
    //To do...
   /* NSString *displayUsername = [[user jidStr] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@",XAppDelegate.currentHost] withString:@""];
    NSString *proxyPath = [NSString stringWithFormat:@"path=/people/%@/avatar/128&return=png",displayUsername];
  //  NSString *avatarUrl = [NSString stringWithFormat:@"%@%@/%@%@",URL_SCHEME,XAppDelegate.currentHost,PROXY_SERVICE,proxyPath];

    NSString *avatarUrl = [NSString stringWithFormat:@"%@%@/%@%@", @"http://", XAppDelegate.currentHost, @"service/proxy/proxy.yookos.php?", proxyPath];
    
    // Avatar
    [friendCell.userImageView.layer setCornerRadius:20.0f];
    [friendCell.userImageView.layer setMasksToBounds:YES];
    
    [friendCell.userImageView setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"placeholder_profile"]];*/
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
