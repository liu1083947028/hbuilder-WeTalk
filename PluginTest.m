//
//  PluginTest.m
//  HBuilder-Hello
//
//  Created by Mac Pro on 14-9-3.
//  Copyright (c) 2014年 DCloud. All rights reserved.
//
@import AVFoundation;
#import "PluginTest.h"
#import "PDRCoreAppFrame.h"
#import "H5WEEngineExport.h"
#import "PDRToolSystemEx.h"
// 扩展插件中需要引入需要的系统库
#import <LocalAuthentication/LocalAuthentication.h>
#import "PLSoftphoneKit/PLSoftphoneKit-Swift.h"
#import <Foundation/Foundation.h>
#import <PushKit/PushKit.h>
#import "AppDelegate.h"


@implementation PGPluginTest

#pragma mark 这个方法在使用WebApp方式集成时触发，WebView集成方式不触发
/*
 * WebApp启动时触发
 * 需要在PandoraApi.bundle/feature.plist/注册插件里添加autostart值为true，global项的值设置为true
 */
- (void) onAppStarted:(NSDictionary*)options{
    NSLog(@"5+ WebApp启动时触发");
}

// 监听基座事件事件
// 应用退出时触发
- (void) onAppTerminate{
    //退出时触发
    NSLog(@"退出时触发");
}

// 应用进入后台时触发
- (void) onAppEnterBackground{
    //
    NSLog(@"APPDelegate applicationDidEnterBackground 事件触发时触发");
}

// 应用进入前天时触发
- (void) onAppEnterForeground{
    //
    NSLog(@"APPDelegate applicationWillEnterForeground 事件触发时触发");
}

#pragma mark 以下为插件方法，由JS触发， WebView集成和WebApp集成都可以触发

//初始化
- (void)initialize:(PGMethod*)command
{
    // 根据传入获取参数
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* token = [command.arguments objectAtIndex:1];
    NSString* rt = [NSString stringWithFormat:@"initialize arguments token=%@",
                    token
                    ];
    [[PLController shared] addDebugLogsWithMsg:rt];
    NSString* flag = @"0";
    id objects[] = { token, @"WeTalkUCPro" };
    id keys[] = { @"token", @"voipAppType" };
    NSUInteger count = sizeof(objects) / sizeof(id);
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects
                                                           forKeys:keys
                                                             count:count];
    if([[PLController shared] InitializeWithParams:dictionary]){
        flag = @"1";
    }
    
    NSArray* pResultString = [NSArray arrayWithObjects:flag, nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}
//添加账号
- (void)addAccount:(PGMethod*)command
{
    // 根据传入获取参数
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* accountName = [command.arguments objectAtIndex:1];
    NSString* password = [command.arguments objectAtIndex:2];
    NSString* domain = [command.arguments objectAtIndex:3];
    NSLog(@"accountName = %@, %@, %@", accountName, password, domain);
    [[PLController shared] addAccountWithUsername:accountName password:password domain:domain accName:accountName displayName:accountName];
    
    NSArray* pResultString = [NSArray arrayWithObjects:accountName, nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}
//删除账号
- (void)removeAccount:(PGMethod*)command
{
    //删除账号，删除推送
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* accountName = [command.arguments objectAtIndex:1];
    NSString* domain = [command.arguments objectAtIndex:2];
    NSString* removePushFlag = [command.arguments objectAtIndex:3];
    NSLog(@"===removePush %@===", removePushFlag);
    Boolean removePush = false;
    if([removePushFlag isEqualToString: @"1"]){
        removePush = true;
    }
    [[PLController shared] removeAccountWithUsername:accountName domain:domain removePushNotification:removePush];
    NSArray* pResultString = [NSArray arrayWithObjects:accountName, nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//注销账户
- (void)unregisterWithAddr:(PGMethod*)command
{
    //删除账号，删除推送
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* addr = [command.arguments objectAtIndex:1];
    NSString* removePushFlag = [command.arguments objectAtIndex:2];
    NSLog(@"===unregisterWithAddr removePush %@===", removePushFlag);
    Boolean removePush = false;
    if([removePushFlag isEqualToString: @"1"]){
        removePush = true;
    }
    [[PLController shared] unregisterWithAddr:addr removePushNotification:removePush];
    NSArray* pResultString = [NSArray arrayWithObjects:@"1", nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//注销所有账户
- (void)unregisterAccountsWithRemovePushNotification:(PGMethod*)command
{
    //删除账号，删除推送
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* removePushFlag = [command.arguments objectAtIndex:1];
    NSLog(@"===unregisterAccountsWithRemovePushNotification removePush %@===", removePushFlag);
    
    NSString* rt = [NSString stringWithFormat:@"2分钟后超时调用unregisterAccountsWithRemovePushNotification removePushFlag=%@",
                   removePushFlag
                    ];
    [[PLController shared] addDebugLogsWithMsg:rt];
    
    Boolean removePush = false;
    if([removePushFlag isEqualToString: @"1"]){
        removePush = true;
    }
    [[PLController shared] unregisterAccountsWithRemovePushNotification: removePush];
    NSArray* pResultString = [NSArray arrayWithObjects:@"1", nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//注册账号
- (void)registerAllAccount:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    [[PLController shared] registerAccounts];
    NSArray* pResultString = [NSArray arrayWithObjects:@"1", nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}
//外呼，开启扬声器
- (void)makeOutgoingCall:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* num = [command.arguments objectAtIndex:1];
    NSString* accountAddr = [command.arguments objectAtIndex:2];
    if([accountAddr isEqual:[NSNull null]] || accountAddr == nil){
        accountAddr = @"";
    }
    
    NSString* rt = [NSString stringWithFormat:@"makeOutgoingCall arguments num=%@, accountAddr=%@",
                    num, accountAddr
                   ];
    [[PLController shared] addDebugLogsWithMsg:rt];

    [[PLController shared] makeOutgoingCallWithHandle:num video:NO accountAddr:accountAddr];
    
    NSArray* pResultString = [NSArray arrayWithObjects:num, nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}
//挂断完，remove账号
- (void)hangupAll:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    [[PLController shared] hangupAll];
    NSArray* pResultString = [NSArray arrayWithObjects:@"", nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}
//注销
- (void)uninitialize:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    [[PLController shared] Uninitialize];
    NSArray* pResultString = [NSArray arrayWithObjects:@"", nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}
//获取SIP账号状态
- (void)getSIPStatus:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* addr = [command.arguments objectAtIndex:1];
    NSString* status = [[PLController shared] getAccountStatusDescriptionWithAddr: addr];
    NSLog(@"sip status%@ %@", addr, status);
    NSString* rt = [NSString stringWithFormat:@"{\"status\":\"%@\"}",
                    status
                    ];
    NSArray* pResultString = [NSArray arrayWithObjects:rt, nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

- (void)getAllAudioDevice:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* hasBlueTooth = @"0";
    
    if([[PLController shared] hasBlueToothAudioInputDevice]){
        hasBlueTooth = @"1";
    }
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:[command.arguments objectAtIndex:1]];
    
    NSString* deviceNames = @"[";
    for (NSString* devName in [[PLController shared] getBlueToothDeviceNames]) {
        if (deviceNames.length == 1) {
            deviceNames = [NSString stringWithFormat:@"%@'%@'", deviceNames, devName];
        } else {
            deviceNames = [NSString stringWithFormat:@"%@,'%@'", deviceNames, devName];
        }
    }
    deviceNames = [NSString stringWithFormat:@"%@]", deviceNames];
    NSLog(@"%@", deviceNames);
    
    NSString* result = [NSString stringWithFormat:@"{\"hasBlueTooth\":\"%@\",\"blueToothList\":\"%@\",\"currentAudioDevice\":\"%@\",\"duration\":\"%@\"}",
                        hasBlueTooth,
                        deviceNames,
                        [[PLController shared] currentAudioOutputDeviceName],
                        [[NSNumber numberWithInteger:[[PLController shared] getCallDurationWithUuid:uuid]]stringValue]
                        ];
    
    NSArray* pResultString = [NSArray arrayWithObjects:result, nil];
    PDRPluginResult *rt = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[rt toJSONString]];
}

- (void)getCurrentAudioDevice:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    //获取当前设备类型和名字
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    AVAudioSessionPortDescription * audioDes = audioSession.currentRoute.inputs[0];
    NSString * audioType = audioDes.portType;
    NSString * audioName = audioDes.portName;
    NSString * outPort = audioSession.currentRoute.outputs[0].portType;
    if ([audioType isEqualToString: AVAudioSessionPortBuiltInMic]) {
        if ([outPort isEqualToString: AVAudioSessionPortBuiltInReceiver] || [outPort isEqualToString: AVAudioSessionPortHeadphones]) {
            // receiver
            audioName = @"earpiece";
        } else if ([outPort isEqualToString: AVAudioSessionPortBuiltInSpeaker]) {
            // speaker
            audioName = @"speaker";
        }
    } else {
        // bluetooth
    }
    NSString* result = [NSString stringWithFormat:@"{\"audioName\":\"%@\",\"audioType\":\"%@\"}",
                        audioName,
                        audioType
                        ];
    NSArray* pResultString = [NSArray arrayWithObjects:result, nil];
    PDRPluginResult *rt = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[rt toJSONString]];
}

//通过通话id找对端号码
- (void)getCallNumber:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:[command.arguments objectAtIndex:1]];
    NSArray* pResultString = [NSArray arrayWithObjects:[[PLController shared] getCallHandleWithUuid:uuid], nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//接受电话
- (void)acceptIncomingCall:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* uid = [command.arguments objectAtIndex:1];
    
    NSString* rtt = [NSString stringWithFormat:@"acceptIncomingCall uuid ==%@",
                    uid
                    ];
    [[PLController shared] addDebugLogsWithMsg:rtt];
    
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:uid];
    
    [[PLController shared] acceptIncomingCallWithUuid:uuid];
    NSString* rt = [NSString stringWithFormat:@"{\"otherNumber\":\"%@\",\"callStatus\":\"%@\",\"uuid\":\"%@\"}",
                        [[PLController shared] getCallHandleWithUuid:uuid],
                        [[PLController shared] getCallStatusWithUuid:uuid],
                        uuid
                        ];
    NSArray* pResultString = [NSArray arrayWithObjects:rt, nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//拒绝电话
- (void)rejectIncomingCall:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* uid = [command.arguments objectAtIndex:1];

    NSString* rt = [NSString stringWithFormat:@"rejectIncomingCall uuid ==%@",
                    uid
                    ];
    [[PLController shared] addDebugLogsWithMsg:rt];
    
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:uid];
    [[PLController shared] rejectIncomingCallWithUuid:uuid];
    NSArray* pResultString = [NSArray arrayWithObjects:@"1", nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//挂断电话
- (void)hangupByUuid:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* uid = [command.arguments objectAtIndex:1];
    NSString* rt = [NSString stringWithFormat:@"hangupByUuid arguments uuid=%@",
                    uid
                    ];
    [[PLController shared] addDebugLogsWithMsg:rt];
    
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:uid];
    [[PLController shared] hangupWithUuid:uuid];
    NSArray* pResultString = [NSArray arrayWithObjects:@"1", nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//获取通话info
- (void)getCallInfo:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:[command.arguments objectAtIndex:1]];
    NSString* rt = [NSString stringWithFormat:@"{\"otherNumber\":\"%@\",\"callStatus\":\"%@\",\"uuid\":\"%@\"}",
                    [[PLController shared] getCallHandleWithUuid:uuid],
                    [[PLController shared] getCallStatusWithUuid:uuid],
                    uuid
                    ];
    NSArray* pResultString = [NSArray arrayWithObjects:rt, nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//静音/取消静音电话
- (void)muteCall:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:[command.arguments objectAtIndex:1]];
    NSString* muteFlag = [command.arguments objectAtIndex:2];
    NSLog(@"===muteFlug %@===", muteFlag);
    Boolean isMute = false;
    if([muteFlag isEqualToString: @"1"]){
        isMute = true;
    }
    [[PLController shared] setMuteCallWithUuid:uuid isMute: isMute];
    NSArray* pResultString = [NSArray arrayWithObjects:@"1", nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//切换音频设备
- (void)switchAudioDevice:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* target = [command.arguments objectAtIndex:1];
    
    [[PLController shared] switchAudioOutputWithTarget:target];
    
    NSArray* pResultString = [NSArray arrayWithObjects:@"1", nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//DTMF
- (void)sendDTMF:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* uid = [command.arguments objectAtIndex:1];
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:uid];
    NSString* digists = [command.arguments objectAtIndex:2];
    
    NSLog(@"sendDTMF== uid = %@, digists=%@", uid, digists);
    [[PLController shared] sendDTMFWithUuid:uuid digits:digists];
    
    NSArray* pResultString = [NSArray arrayWithObjects:@"1", nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//getVoipToken
- (void)getVoipToken:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    
    NSString* token = [[PLController shared] getToken];
    NSLog(@"===_voipToken==%@", token);
    NSString* rt = [NSString stringWithFormat:@"{\"voipToken\":\"%@\"}",
                    token
                    ];
    NSArray* pResultString = [NSArray arrayWithObjects:rt, nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//获取sdk日志
- (void)getSDKLogs:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    
    NSString* logs = [[PLController shared] getDebugLogs];
    NSLog(@"[[PLController shared] getDebugLogs]==%@", logs);
    //[[PLController shared] cleanupDebugLogs];
    
    /**
     *  Logs
     */
    NSMutableString *mailUrl = [NSMutableString string];
    [mailUrl appendString:@"mailto:frank.liu@polylink.net"];
    [mailUrl appendString:@"?subject= Logs！"];
    [mailUrl appendFormat:@"&body=%@", logs];
    // 打开地址
    NSString *mailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailPath]];
    
    NSString* rt = [NSString stringWithFormat:@"%@",
                        logs
                        ];
    NSArray* pResultString = [NSArray arrayWithObjects:rt, nil];
    
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//删除账号
- (void)removeAllAccount:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    
    [[PLController shared] removeAllWithRemovePushNotification:false];

    NSArray* pResultString = [NSArray arrayWithObjects:@"1", nil];
    
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//创建本地通知
- (void)createLocalMsg:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSString* title = [command.arguments objectAtIndex:1];
    NSString* content = [command.arguments objectAtIndex:2];
    NSString* payload = [command.arguments objectAtIndex:3];
    NSString* type = [command.arguments objectAtIndex:4];
    NSString* msgSound = [command.arguments objectAtIndex:5];
    
    [self sendNoticationWithHandle:title body:content payload:payload type:type msgSound:msgSound];
    NSArray* pResultString = [NSArray arrayWithObjects:@"1", nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//获取当前呼叫数
- (void)getCallCount:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    
    NSArray* pResultString = [NSArray arrayWithObjects:[[NSNumber numberWithInteger:[[PLController shared] callCount]]stringValue], nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//注册为voip通知
- (void)registerVoipNotifications:(PGMethod*)command
{
    NSString* cbId = [command.arguments objectAtIndex:0];
    NSArray* pResultString = [NSArray arrayWithObjects:@"1", nil];
    PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray: pResultString];
    [self toCallback:cbId withReslut:[result toJSONString]];
}

//发送本地通知
- (void)sendNoticationWithHandle:(NSString*)title body:(NSString*)body payload:(NSString*)payload type:(NSString*)type msgSound:(NSString*)msgSound  {
    if (title == NULL || type == NULL) { return; }
    NSLog(@"Send local notification %@, '%@'", title, type);
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;

    UNNotificationAction *actionAccept = [UNNotificationAction actionWithIdentifier:@"acceptNotificationCall" title:NSLocalizedString(@"接听", nil) options:UNNotificationActionOptionForeground];
    UNNotificationAction *actionReject = [UNNotificationAction actionWithIdentifier:@"rejectNotificationCall" title:NSLocalizedString(@"拒绝", nil) options:UNNotificationActionOptionNone];
    
    UNNotificationCategory* category = [UNNotificationCategory categoryWithIdentifier:@"plCategory"
                                                                              actions:@[actionAccept, actionReject]
                                                                    intentIdentifiers:@[]
                                                                              options:UNNotificationCategoryOptionNone];
    
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = title;
    content.body = body;
    [content setValue:@(YES) forKeyPath:@"shouldAlwaysAlertWhileAppIsForeground"];//很重要的设置,前后台都需要显示通知
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:payload,@"payload",nil];
    content.userInfo = dict;
    if([msgSound isEqualToString:@"1"]){
        content.sound = [UNNotificationSound defaultSound];
    }
    
    if([type isEqualToString:@"voipMsg"]){
//        NSSet *categories = [NSSet setWithObject:category];
//        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
//        content.categoryIdentifier = @"plCategory";
    }

    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
    
    
    NSTimeInterval seconds = [NSDate timeIntervalSinceReferenceDate];
    NSString *identifier = [NSString stringWithFormat:@"localNotification.%f", seconds];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Popup local notification failed, error = '%@'",error);
        }
    }];
}

@end
