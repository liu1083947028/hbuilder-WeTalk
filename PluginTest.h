//
//  PluginTest.h
//  HBuilder-Hello
//
//  Created by Mac Pro on 14-9-3.
//  Copyright (c) 2014年 DCloud. All rights reserved.
//

#include "PGPlugin.h"
#include "PGMethod.h"
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface PGPluginTest : PGPlugin<UNUserNotificationCenterDelegate>

@property (strong, nonatomic, readonly) NSString *vvvToken;

- (void)initialize:(PGMethod*)command;
- (void)addAccount:(PGMethod*)command;
- (void)registerAllAccount:(PGMethod*)command;
- (void)removeAccount:(PGMethod*)command;
- (void)makeOutgoingCall:(PGMethod*)command;
- (void)hangupAll:(PGMethod*)command;
- (void)uninitialize:(PGMethod*)command;
- (void)getAllAudioDevice:(PGMethod*)command;
- (void)getCurrentAudioDevice:(PGMethod*)command;
- (void)getCallNumber:(PGMethod*)command;
- (void)acceptIncomingCall:(PGMethod*)command;
- (void)rejectIncomingCall:(PGMethod*)command;
- (void)hangupByUuid:(PGMethod*)command;
- (void)getCallInfo:(PGMethod*)command;
- (void)muteCall:(PGMethod*)command;
- (void)switchAudioDevice:(PGMethod*)command;
- (void)sendDTMF:(PGMethod*)command;
- (void)unregisterWithAddr:(PGMethod*)command;
- (void)unregisterAccountsWithRemovePushNotification:(PGMethod*)command;
- (void)registerVoipNotifications:(PGMethod*)command;
- (void)getVoipToken:(PGMethod*)command;
- (void)getSDKLogs:(PGMethod*)command;
- (void)removeAllAccount:(PGMethod*)command;
- (void)createLocalMsg:(PGMethod*)command;
- (void)getCallCount:(PGMethod*)command;

@end
