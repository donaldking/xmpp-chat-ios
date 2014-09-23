//
//  Setting.h
//  TChat
//
//  Created by SWATI KIRVE on 10/08/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Setting : NSManagedObject

@property (nonatomic, retain) NSNumber * isSoundOn;
@property (nonatomic, retain) NSNumber * showLastSeen;

@end
