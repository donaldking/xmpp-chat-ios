//
//  TCFriendsTableViewCell.h
//  TChat
//
//  Created by SWATI KIRVE on 07/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface TCFriendsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userJIDLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@end
