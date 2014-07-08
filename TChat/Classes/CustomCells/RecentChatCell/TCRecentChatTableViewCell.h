//
//  TCRecentChatTableViewCell.h
//  TChat
//
//  Created by SWATI KIRVE on 08/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCRecentChatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userJIDLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *chatMsgLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;

@end
