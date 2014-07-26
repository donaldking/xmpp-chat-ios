//
//  TCCreateGroupViewController.m
//  TChat
//
//  Created by SWATI KIRVE on 24/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import "TCCreateGroupViewController.h"
#import "TCConstants.h"

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

- (IBAction)doneAction:(UIBarButtonItem *)sender
{
      [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backAction:(UIBarButtonItem *)sender
{
      [self dismissViewControllerAnimated:YES completion:nil];
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
