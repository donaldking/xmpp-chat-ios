//
//  RecentChat.h
//  TChat
//
//  Created by SWATI KIRVE on 17/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RecentChat : NSManagedObject

@property (nonatomic, retain) NSString * chatWithUser;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * created_at;
@property (nonatomic, retain) NSString * message_id;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * receiver;
@property (nonatomic, retain) NSString * sender;
@property (nonatomic, retain) NSString * time_stamp;

@end
