//
//  TCFriendChatCell.h
//  TChat
//
//  Created by SWATI KIRVE on 11/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DTAttributedTextContentView.h"

@interface TCFriendChatCell : UITableViewCell<UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *date;
@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UIImageView *avatar;
//@property (nonatomic, strong) IBOutlet DTAttributedTextContentView *message;

@end
