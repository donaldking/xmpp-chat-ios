//
//  YCRecentsViewController.h
//  YChat
//
//  Created by SWATI KIRVE on 04/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCRecentsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray* chats;

@end
