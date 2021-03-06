//
//  TCAPIMethods.m
//  TChat
//
//  Created by SWATI KIRVE on 11/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import "TCAPIMethods.h"
#import "TCAppDelegate.h"
#import "RecentChat.h"

@implementation TCAPIMethods

-(void)doPostWithDictionary:(NSDictionary *)dictionary andCallback:(postCompletedBlock)completionResponse{
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    NSURL *baseUrl = [NSURL URLWithString:[dictionary valueForKey:@"baseUrl"]];
    NSString *api = [dictionary valueForKey:@"api"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:api parameters:dictionary];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        completionResponse(@"doPostWithDictionary:OK");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        completionResponse(@"doPostWithDictionary:ERROR");
    }];
    
    [operationQueue addOperation:operation];
}

-(void)doGetWithDictionary:(NSDictionary *)dictionary andCallback:(getCompletedBlock)completionResponse{
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    NSURL *baseUrl = [NSURL URLWithString:[dictionary valueForKey:@"baseUrl"]];
    NSString *api = [dictionary valueForKey:@"api"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:api parameters:dictionary];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSData *data = [[operation responseString] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *values = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        //NSLog(@"Will persist total objects: %i",values.count);
        
        [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            // Create message to send as dictionary
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [[values valueForKey:@"sender"] objectAtIndex:idx],@"sender",
                                    [[values valueForKey:@"receiver"] objectAtIndex:idx],@"receiver",
                                    [[values valueForKey:@"message"] objectAtIndex:idx],@"message",
                                    [[values valueForKey:@"time_stamp"] objectAtIndex:idx],@"message_date",
                                    [[values valueForKey:@"messageType"] objectAtIndex:idx],@"messageType",
                                    [NSNumber numberWithBool:[[[values valueForKey:@"isGroupMessage"] objectAtIndex:idx] boolValue]],@"isGroupMessage",
                                    @"0",@"status",
                                    nil];
            
            [XAppDelegate receiveAndPersistObjectForEntityName:@"Chat" inManagedObjectContext:XAppDelegate.managedObjectContext withDictionary:params andCallback:^(id completionResponse) {
                //
            }];
            
            //NSLog(@"Persisted object at index %i", idx);
            
        }];
        completionResponse(@"doGetWithDictionary:OK");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        completionResponse(@"doGetWithDictionary:ERROR");
    }];
    
    [operationQueue addOperation:operation];
}



-(void)doGetRecentChatWithDictionary:(NSDictionary *)dictionary andCallback:(getCompletedBlock)completionResponse{
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    NSURL *baseUrl = [NSURL URLWithString:[dictionary valueForKey:@"baseUrl"]];
    NSString *api = [dictionary valueForKey:@"api"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:api parameters:dictionary];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSData *data = [[operation responseString] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *values = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        //NSLog(@"Will persist total objects: %i",values.count);
        
        [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *lastMessage = [[values valueForKey:@"lastMessage"] objectAtIndex:idx];
            // Create message to send as dictionary
            
            NSLog(@"%hhd", [[lastMessage valueForKey:@"isGroupMessage"] boolValue]);
             NSLog(@"%@", [lastMessage valueForKey:@"isGroupMessage"]);
            
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [[values valueForKey:@"chatWithUser"] objectAtIndex:idx],@"chatWithUser",
                                    [[values valueForKey:@"name"] objectAtIndex:idx],@"name",
                                    [lastMessage valueForKey:@"created_at"],@"created_at",
                                    [lastMessage valueForKey:@"id"],@"message_id",
                                    [lastMessage valueForKey:@"isRead"],@"isRead",
                                    [lastMessage valueForKey:@"message"],@"message",
                                    [lastMessage valueForKey:@"receiver"],@"receiver",
                                    [lastMessage valueForKey:@"sender"],@"sender",
                                    [lastMessage valueForKey:@"time_stamp"],@"time_stamp",
                                    [lastMessage valueForKey:@"messageType"],@"messageType",
                                    [NSNumber numberWithBool:[[lastMessage valueForKey:@"isGroupMessage"] boolValue]],@"isGroupMessage",
                                    nil];
        
            //NSLog(@"id:%@", [[values valueForKey:@"chatWithUser"] objectAtIndex:idx]);
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatWithUser=%@", [[values valueForKey:@"chatWithUser"] objectAtIndex:idx]];
 
            [XAppDelegate checkIfObjectExistsForEntityName:@"RecentChat" withPredicate:predicate inManagedObjectContext:XAppDelegate.managedObjectContext andCallback:^(id completionResponse) {
                if ([completionResponse isEqualToString:@"checkIfObjectExistsForEntityName:YES"]) {
                    [XAppDelegate updateAttributeForEntityName:@"RecentChat" inManagedObjectContext:XAppDelegate.managedObjectContext withDictionary:dictionary andPredicate:predicate andCallback:^(id completionResponse){
                        //NSLog(@"update Recent Chat model");
                    }];
                }
                else{
                    [XAppDelegate persistObjectForEntityName:@"RecentChat" inManagedObjectContext:XAppDelegate.managedObjectContext withDictionary:dictionary andCallback:^(id completionResponse){
                        //NSLog(@"persist Recent Chat model");
                    }];
                }
            }];

        }];
        completionResponse(@"doGetWithDictionary:OK");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        completionResponse(@"doGetWithDictionary:ERROR");
    }];
    
    [operationQueue addOperation:operation];
}

-(void)doGetGroupsWithDictionary:(NSDictionary*)dictionary andCallback:(getCompletedBlock)completionResponse
{
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    NSURL *baseUrl = [NSURL URLWithString:[dictionary valueForKey:@"baseUrl"]];
    NSString *api = [dictionary valueForKey:@"api"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:api parameters:dictionary];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSData *data = [[operation responseString] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *values = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        //NSLog(@"Will persist total objects: %i",values.count);
        
        [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [obj valueForKey:@"group_name"],@"name",
                                        [obj valueForKey:@"group_id"],@"roomJID",
                                        nil];
            
            //NSLog(@"id:%@", [[values valueForKey:@"chatWithUser"] objectAtIndex:idx]);
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roomJID=%@", [obj valueForKey:@"group_id"]];
            
            [XAppDelegate checkIfObjectExistsForEntityName:@"Room" withPredicate:predicate inManagedObjectContext:XAppDelegate.managedObjectContext andCallback:^(id completionResponse) {
                if ([completionResponse isEqualToString:@"checkIfObjectExistsForEntityName:YES"]) {
                    [XAppDelegate updateAttributeForEntityName:@"Room" inManagedObjectContext:XAppDelegate.managedObjectContext withDictionary:dictionary andPredicate:predicate andCallback:^(id completionResponse){
                        //NSLog(@"update Recent Chat model");
                    }];
                }
                else{
                    [XAppDelegate persistObjectForEntityName:@"Room" inManagedObjectContext:XAppDelegate.managedObjectContext withDictionary:dictionary andCallback:^(id completionResponse){
                        //NSLog(@"persist Recent Chat model");
                    }];
                }
            }];
            
        }];
        completionResponse(@"doGetWithDictionary:OK");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        completionResponse(@"doGetWithDictionary:ERROR");
    }];
    
    [operationQueue addOperation:operation];
}


-(void)doGetProfileWithDictionary:(NSDictionary*)dictionary andCallback:(getCompletedBlock)completionResponse
{
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    NSURL *baseUrl = [NSURL URLWithString:[dictionary valueForKey:@"baseUrl"]];
    NSString *api = [dictionary valueForKey:@"api"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:api parameters:dictionary];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSData *data = [[operation responseString] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *values = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        //NSLog(@"Will persist total objects: %i",values.count);
        
        [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [obj valueForKey:@"fullName"],@"fullname",
                                        nil];
            
            [XAppDelegate clearObjectsForEntityName:@"UserProfile" inManagedObjectContext:XAppDelegate.managedObjectContext andCallback:^(id completionResponse) {
            }];

        
            XAppDelegate.userNickName = [obj valueForKey:@"fullName"];
            [XAppDelegate persistObjectForEntityName:@"UserProfile" inManagedObjectContext:XAppDelegate.managedObjectContext withDictionary:dictionary andCallback:^(id completionResponse){
                        //NSLog(@"persist Recent Chat model");
                    }];
        
        }];
        completionResponse(@"doGetWithDictionary:OK");
        
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        completionResponse(@"doGetWithDictionary:ERROR");
    }];
    
    [operationQueue addOperation:operation];
}


@end
