//
//  TCConstants.h
//  TChat
//
//  Created by SWATI KIRVE on 04/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(int, PresenceStatus){
    online = 0,
    away,
    invisible,
    offline,
};


typedef NS_ENUM(int,DIRECTION) {
    NONE,
    RIGHT,
    LEFT,
    UP,
    DOWN,
    CRAZY,
};

#define PLACEHOLDER_IMAGE @"placeholder_profile"

@interface TCConstants : NSObject

extern NSString * URL_SCHEME;
extern NSString * XMPP_UAT_HOST;
extern NSString * XMPP_LIVE_HOST;
extern NSString * PROXY_SERVICE;


@end
