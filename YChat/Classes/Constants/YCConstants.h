//
//  YCConstants.h
//  YChat
//
//  Created by SWATI KIRVE on 04/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import <Foundation/Foundation.h>

#define URL_SCHEME @"http://";
#define XMPP_UAT_HOST @"uat.yookoschat.com";
#define XMPP_LIVE_HOST @"yookoschat.com";
#define PROXY_SERVICE @"service/proxy/proxy.yookos.php?";

typedef NS_ENUM(int, PresenceStatus){
    online = 0,
    away,
    invisible,
    offline,
};

@interface YCConstants : NSObject

@end
