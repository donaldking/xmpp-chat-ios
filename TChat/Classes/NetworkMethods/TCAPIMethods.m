//
//  TCAPIMethods.m
//  TChat
//
//  Created by SWATI KIRVE on 11/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import "TCAPIMethods.h"
#import "TCAppDelegate.h"

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
        
        NSLog(@"Will persist total objects: %i",values.count);
        
        [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            // Create message to send as dictionary
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [[values valueForKey:@"sender"] objectAtIndex:idx],@"sender",
                                    [[values valueForKey:@"receiver"] objectAtIndex:idx],@"receiver",
                                    [[values valueForKey:@"message"] objectAtIndex:idx],@"message",
                                    [[values valueForKey:@"time_stamp"] objectAtIndex:idx],@"message_date",
                                    @"0",@"status",
                                    nil];
            
            [XAppDelegate receiveAndPersistObjectForEntityName:@"ChatMessages" inManagedObjectContext:XAppDelegate.managedObjectContext withDictionary:params andCallback:^(id completionResponse) {
                //
            }];
            
            NSLog(@"Persisted object at index %i", idx);
            
        }];
        completionResponse(@"doGetWithDictionary:OK");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        completionResponse(@"doGetWithDictionary:ERROR");
    }];
    
    [operationQueue addOperation:operation];
}



@end
