//
//  YCAppDelegate.h
//  YChat
//
//  Created by SWATI KIRVE on 04/07/2014.
//  Copyright (c) 2014 sharaai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

/*
 * Import TUSK XMPP CLASSES, CORE and DEPENDENCIES
 *
 */
#import <TUSKXMPPLIB/TUSKXMPPLIB.h>
#import <TUSKXMPPLIB/DDLog.h>
#import <TUSKXMPPLIB/DDTTYLogger.h>

#import "TCChatConnectionProtocol.h"
#import "TCConstants.h"

#define XAppDelegate ((TCAppDelegate*)[[UIApplication sharedApplication] delegate])

typedef void(^chatMessageSentResponseBlock) (NSString *response);
typedef void(^requestCompletedBlock) (id completionResponse);

@interface TCAppDelegate : UIResponder <UIApplicationDelegate, XMPPReconnectDelegate, TCChatConnectionProtocol>
{
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
}

@property (nonatomic, strong) id<TCChatConnectionProtocol> chatConnectionDelegate;

@property (nonatomic) BOOL isXmppConnected;
@property (nonatomic) BOOL allowSelfSignedCertificates;
@property (nonatomic) BOOL allowSSLHostNameMismatch;

@property (nonatomic, strong) NSString *profileName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic) PresenceStatus presence;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UIStoryboard *stroyboard;
@property (nonatomic, strong) UINavigationController *navController;

@property (nonatomic, strong) NSString *thisPassword;
@property (nonatomic, strong) NSString *XMPP_RESOURCE_NAME;
@property (nonatomic, strong) NSString *currentHost;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

#pragma mark - XMPP
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, retain) NSTimer *backgroundTimer;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;



- (void) prepareXmppChat;
- (void) setupStream;
- (void) teardownStream;

- (void) doLoginForUsername:(NSString*)theUsername andPassword:(NSString*)thePassword andCallback:(requestCompletedBlock)doLoginCompletionResponse;
- (BOOL) connectForUsername:(NSString*)theUsername andPasswrod:(NSString*)thePassword andCallBack:(requestCompletedBlock)responseBlock;
- (void) disconnect;

- (void) doLogout;
- (void) getUserProfileObjectAndCallback:(requestCompletedBlock)getUserProfileCompletionResponse;
- (void) checkIfObjectExistsForEntityName:(NSString*)entityName inManagedObjectContext:(NSManagedObjectContext*)context
                             andCallback:(requestCompletedBlock)completionResponse;

- (void) sendAndPersistObjectForEntityName:(NSString*)entityName inManagedObjectContext:(NSManagedObjectContext*)context
                           withDictionary:(NSDictionary*)dictionary andCallback:(requestCompletedBlock)completionResponse;

- (void) receiveAndPersistObjectForEntityName:(NSString*)entityName inManagedObjectContext:(NSManagedObjectContext*)context
                              withDictionary:(NSDictionary*)dictionary andCallback:(requestCompletedBlock)completionResponse;

-(void) notifyWhichViewIsActive;
-(void) newChatNotificationFromBuddy:(NSString *)buddy withMessage:(NSString *)message;
- (void) clearObjectsForEntityName:(NSString*)entityName inManagedObjectContext:(NSManagedObjectContext*)context
                      andCallback:(requestCompletedBlock)completionResponse;
- (void) clearObjectForEntityName:(NSString*)entityName withPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)context andCallback:(requestCompletedBlock)completionResponse;
- (void) checkIfObjectExistsForEntityName:(NSString*)entityName withPredicate:(NSPredicate*)predicate
                  inManagedObjectContext:(NSManagedObjectContext*)context andCallback:(requestCompletedBlock)completionResponse;

#pragma mark - CoreData
- (void) saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
