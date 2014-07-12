//
//  TCChatMessageProtocol.h
//  TChat
//
//  Created by SWATI KIRVE on 11/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCChatMessageProtocol <NSObject>

-(void)composingMessageReceived:(id)messageContent;
-(void)newMessageReceived:(id)messageContent;
-(void)emoticonSelected:(id)selection;

@end
