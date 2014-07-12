//
//  TCAPIMethods.h
//  TChat
//
//  Created by SWATI KIRVE on 11/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@class TCAppDelegate;

typedef void(^postCompletedBlock) (id completionResponse);
typedef void(^getCompletedBlock) (id completionResponse);

@interface TCAPIMethods : NSObject

-(void)doPostWithDictionary:(NSDictionary*)dictionary andCallback:(postCompletedBlock)completionResponse;
-(void)doGetWithDictionary:(NSDictionary*)dictionary andCallback:(getCompletedBlock)completionResponse;

@end
