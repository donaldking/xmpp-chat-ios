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
#import "TCGroupChatViewController.h"

@interface TCGroupsViewController ()
@property (nonatomic,strong) NSMutableArray *rooms;

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

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
    [self getGroups];
}


-(void)loadData
{
    if (self.rooms)
        self.rooms =nil;
    self.rooms = [[NSMutableArray alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Room"
                                              inManagedObjectContext:XAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSError *error=nil;
    NSArray *fetchedObjects = [XAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in fetchedObjects)
    {
        Room *currentRoom = (Room *)obj;
        [self.rooms addObject:currentRoom];
    }
    //reload the table view
    [self.tableView reloadData];
}

-(void)getGroups
{
    NSString *sender = XAppDelegate.username;
    
    NSMutableDictionary *dicToApi = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%@%@",URL_SCHEME,XAppDelegate.currentHost],@"baseUrl",
                                     [NSString stringWithFormat:@"mobileservices/v1/get_groups_for_user.php?user_id=%@",sender],@"api",
                                     nil];
    
    
    [XAppDelegate.ApiMethods doGetGroupsWithDictionary:dicToApi andCallback:^(id completionResponse) {
        NSLog(@"Completion response: %@",completionResponse);
        
        if ([completionResponse isEqualToString:@"doGetWithDictionary:OK"]) {
            NSLog(@"received success response");
            //TODO
            [self loadData];
        }
    }];
    
    
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
}


#pragma mark UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	return self.rooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
    {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
	
	Room *room = [self.rooms objectAtIndex:indexPath.row];
	
	cell.textLabel.text = room.name;
	
	return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Room *room = [self.rooms objectAtIndex:indexPath.row];
    
    TCGroupChatViewController *groupChatViewController = [XAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"groupChatView"];
        
    groupChatViewController.chatWithUser = [ room.roomJID stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@",XMPP_CONFERENCE_UAT_HOST] withString:@""];
        
    groupChatViewController.hidesBottomBarWhenPushed = YES;
        
    groupChatViewController.navigationItem.title = room.name;
        
    [self.navigationController pushViewController:groupChatViewController animated:YES];
    
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
