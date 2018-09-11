//
//  AppDelegate.m
//  Pandora
//
//  Created by Mac Pro_C on 12-12-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "PDRCore.h"
#import "PDRCommonString.h"
#import "ViewController.h"
#import "PDRCoreApp.h"
#import "DCADManager.h"
#import "PDRCoreAppManager.h"
#import "PLSoftphoneKit/PLSoftphoneKit-Swift.h"

// 示例默认带开屏广告，如果不需要广告，可注释下面一行
#define dcSplashAd

@interface AppDelegate () <DCADManagerDelgate, PDRCoreDelegate>
@property (strong, nonatomic) ViewController *h5ViewContoller;
@end

@implementation AppDelegate

@synthesize window = _window;
#pragma mark -
#pragma mark app lifecycle

- (NSMutableArray*)searchViews:(NSArray*)views{
    
    NSMutableArray *frames = [NSMutableArray array];
    //遍历view
    for (UIView *temp in views) {
        
        if ([temp isMemberOfClass:[PDRCoreAppFrame class]]) {
            
            [frames addObject:temp];
        }
        if ([temp subviews]) {
            
            NSMutableArray *tempArray = [self searchViews:[temp subviews]];
            
            for (UIView *tempView in tempArray) {
                
                if ([tempView isMemberOfClass:[PDRCoreAppFrame class]]) {
                    
                    [frames addObject:tempView];
                }
            }
        }
    }
    //返回值 frames 为从该层级中找到的 PDRCoreAppFrame
    return frames;
}

-(void)evaluatingJavaScriptFromString:(NSString*)string{
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    NSArray *views = [[[window rootViewController] view] subviews];
    
    NSArray *frames = [self searchViews:views];
    
    NSLog(@"views == %@",frames);
    
    for (PDRCoreAppFrame *appFrame in frames) {
        /*这里需要注意执行异步任务，在block内需要回到主线程来进行JS event的调用，但是如果还是使用
         dispath_get_main_queue的话会造成调用JS有alert的话线程会死锁,具体原因也不是特别清晰，
         在stackOverFlow中看到应该是JS和OC不同alert线程的原因
         */
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [appFrame performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:string waitUntilDone:NO];
            
        });
    }
}

-(void)fireEvent:(NSString*)event args:(NSString *)args{
    NSString *evalStr = nil;
    
    if (args) {
        //创建js事件
        evalStr = [NSString stringWithFormat:@"\
                   var pathEvent = document.createEvent('HTMLEvents');\
                   pathEvent.initEvent('%@', true, true);\
                   pathEvent.eventType = 'message';\
                   pathEvent.arguments = '%@';\
                   document.dispatchEvent(pathEvent);",event,args];
    }else{
        evalStr = [NSString stringWithFormat:@"\
                   var pathEvent = document.createEvent('HTMLEvents');\
                   pathEvent.initEvent('%@', true, true);\
                   pathEvent.eventType = 'message';\
                   document.dispatchEvent(pathEvent);", event];
    }
    //调用上述方法
    [self evaluatingJavaScriptFromString:evalStr];
}

- (void) accountStatusChanged:(NSNotification*) notification
{
    NSDictionary* dict = notification.userInfo;
    
    NSString* result = [NSString stringWithFormat:@"{\"addr\":\"%@\",\"status\":\"%@\"}", [dict objectForKey:@"addr"], [dict objectForKey:@"status"]];
    
    [self fireEvent:@"accountStatusChanged" args: result];
}

- (void) callStatusChanged:(NSNotification*) notification
{
    NSDictionary* dict = notification.userInfo;
    
    NSString* result = [NSString stringWithFormat:@"{\"uuid\":\"%@\",\"number\":\"%@\", \"status\":\"%@\"}", [dict objectForKey:@"uuid"], [dict objectForKey:@"number"], [dict objectForKey:@"status"]];
    NSLog(@"===callStatusChanged result = %@==", result);
    
    [self fireEvent:@"callStatusChanged" args: result];
}

- (void) newIncomingCall:(NSNotification*) notification
{
    NSDictionary* dict = notification.userInfo;
    
    NSString* result = [NSString stringWithFormat:@"{\"uuid\":\"%@\",\"phone\":\"%@\"}", [dict objectForKey:@"uuid"], [dict objectForKey:@"phone"]];
    
    [[PLController shared] addDebugLogsWithMsg:result];
    [self fireEvent:@"newIncomingCall" args: result];
}

- (void) networkBreak:(NSNotification*) notification
{
    NSDictionary* dict = notification.userInfo;
    
    NSString* result = [NSString stringWithFormat:@"{\"uuid\":\"%@\"}", [dict objectForKey:@"uuid"]];
    
    [self fireEvent:@"networkBreak" args: result];
}

- (void) networkResume:(NSNotification*) notification
{
    NSDictionary* dict = notification.userInfo;
    
    NSString* result = [NSString stringWithFormat:@"{\"uuid\":\"%@\"}", [dict objectForKey:@"uuid"]];
    
    [self fireEvent:@"networkResume" args: result];
}

- (void) audioDeviceChanged:(NSNotification*) notification
{
    NSDictionary* dict = notification.userInfo;
    
    NSString* result = [NSString stringWithFormat:@"{\"uuid\":\"%@\",\"type\":\"%@\"}", [dict objectForKey:@"uuid"], [dict objectForKey:@"type"]];
    
    [self fireEvent:@"audioDeviceChanged" args: result];
}

- (void) getVoipToken:(NSNotification*) notification
{
    NSDictionary* dict = notification.userInfo;
    NSString* result = [NSString stringWithFormat:@"{\"voipToken\":\"%@\"}", [dict objectForKey:@"voipToken"]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self fireEvent:@"aaaaaaa" args: result];
    });
    
}

- (void) newCallRecordGenerated:(NSNotification*) notification
{
    NSDictionary* dict = notification.userInfo;
    
    NSString* result = [NSString stringWithFormat:@"{\"handle\":\"%@\",\"start\":\"%@\",\"duration\":\"%@\",\"isOutgoing\":\"%@\",\"accountAddress\":\"%@\",\"endType\":\"%@\"}",
                        [dict objectForKey:@"handle"],
                        [dict objectForKey:@"start"],
                        [dict objectForKey:@"duration"],
                        [dict objectForKey:@"isOutgoing"],
                        [dict objectForKey:@"accountAddress"],
                        [dict objectForKey:@"endType"]
                        ];
    
    [self fireEvent:@"newCallRecordGenerated" args: result];
}

void UncaughtExceptionHandler(NSException *exception) {
    /**
     *  获取异常崩溃信息
     */
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *content = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[callStack componentsJoinedByString:@"\n"]];
    
    /**
     *  把异常崩溃信息发送至开发者邮件
     */
    NSMutableString *mailUrl = [NSMutableString string];
    [mailUrl appendString:@"mailto:frank.liu@polylink.net"];
    [mailUrl appendString:@"?subject=程序异常崩溃，请配合发送异常报告，谢谢合作！"];
    [mailUrl appendFormat:@"&body=%@", content];
    // 打开地址
    NSString *mailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailPath]];
}

/*
 * @Summary:程序启动时收到push消息
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    //注册VOIP PUSH
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    UIUserNotificationSettings *userNotifySetting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifySetting];
    
    
    _testBits = 0;
    BOOL ret = [PDRCore initEngineWihtOptions:launchOptions
                                  withRunMode:PDRCoreRunModeNormal withDelegate:self];
    
    DCADManager *adManager = [DCADManager adManager];
    UIViewController* adViewController = [adManager getADViewController];
    adManager.delegate = self;
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    
    ViewController *viewController = [[ViewController alloc] init];
    self.h5ViewContoller = viewController;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.rootViewController = navigationController;
    navigationController.navigationBarHidden = YES;
    if ( adViewController ) {
        [navigationController pushViewController:adViewController animated:NO];
    } else {
        [self startMainApp];
        self.h5ViewContoller.showLoadingView = YES;
    }
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    //监听事件
    //SIP账号状态变动事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountStatusChanged:) name:@"PLControllerNotificationAccountStatusChanged" object:nil];
    //通话状态变动事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callStatusChanged:) name:@"PLControllerNotificationCallStatusChanged" object:nil];
    //来电事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newIncomingCall:) name:@"PLControllerNotificationNewIncomingCall" object:nil];
    //通话中网络中断事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkBreak:) name:@"PLCallNotificationNetworkBreak" object:nil];
    //通话中网络中断恢复事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkResume:) name:@"PLControllerNotificationCallNetworkResume" object:nil];
    //音频设备变动事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioDeviceChanged:) name:@"PLControllerNotificationAudioDeviceChanged" object:nil];
    //新电话记录事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newCallRecordGenerated:) name:@"PLControllerNotificationNewCallRecordGenerated" object:nil];
    
    //voip token
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getVoipToken:) name:@"voipRemoteNotificationsRegistered" object:nil];
    
    return ret;
}

//获取voip token
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
    [[PLController shared] addDebugLogsWithMsg:@"getvoiptoken pushRegistry=====start"];
    NSString *str = [NSString stringWithFormat:@"%@",credentials.token];
    NSString *tokenStr = [[[str stringByReplacingOccurrencesOfString:@"<" withString:@""]
                           stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* rt = [NSString stringWithFormat:@"pushRegistry tokenStr=%@",
                    tokenStr
                    ];
    [[PLController shared] addDebugLogsWithMsg:rt];
    [[PLController shared] setTokenWithToken:tokenStr];
}

//收到voip push
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type{
    
    [[PLController shared] addDebugLogsWithMsg:@"receive incoming push"];
    
    UIUserNotificationType theType = [UIApplication sharedApplication].currentUserNotificationSettings.types;
    
    if (theType == UIUserNotificationTypeNone)
    {
        UIUserNotificationSettings *userNotifySetting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifySetting];
    }
    
    NSDictionary * dic = payload.dictionaryPayload;
    
    NSLog(@"dic  %@",dic);
    
    if ([dic[@"cmd"] isEqualToString:@"call"]) {
        UILocalNotification *backgroudMsg = [[UILocalNotification alloc] init];
        backgroudMsg.alertBody= @"You receive a new call";
        backgroudMsg.soundName = @"ring.caf";
        backgroudMsg.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:backgroudMsg];
    }else if([dic[@"cmd"] isEqualToString:@"cancel"]){
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        UILocalNotification * wei = [[UILocalNotification alloc] init];
        wei.alertBody= [NSString stringWithFormat:@"%ld 个未接来电",(long)[[UIApplication sharedApplication]applicationIconBadgeNumber]];
        wei.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber];
        [[UIApplication sharedApplication] presentLocalNotificationNow:wei];
    }
}

#pragma mark -
#pragma mark - core delegate
- (BOOL)interruptCloseSplash {
    return [[DCADManager adManager] interruptCloseSplash];//self.isAdInterruptCloseLoadingPage;
}
    
-(BOOL)getStatusBarHidden {
    return [self.h5ViewContoller getStatusBarHidden];
}
    
-(UIStatusBarStyle)getStatusBarStyle {
    return [self.h5ViewContoller getStatusBarStyle];
}
-(void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    [self.h5ViewContoller setStatusBarStyle:statusBarStyle];
}
    
-(void)wantsFullScreen:(BOOL)fullScreen
    {
        [self.h5ViewContoller wantsFullScreen:fullScreen];
    }
    
- (void)settingLoadEnd {
    [DCADManager adManager];
}

- (void)startMainApp {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[PDRCore Instance] start];
    });
}

#pragma mark - 系统事件通知
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem
  completionHandler:(void(^)(BOOL succeeded))completionHandler{
    [PDRCore handleSysEvent:PDRCoreSysEventPeekQuickAction withObject:shortcutItem];
    completionHandler(true);
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    [PDRCore handleSysEvent:PDRCoreSysEventBecomeActive withObject:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application{
    [PDRCore handleSysEvent:PDRCoreSysEventResignActive withObject:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    [PDRCore handleSysEvent:PDRCoreSysEventEnterBackground withObject:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    [PDRCore handleSysEvent:PDRCoreSysEventEnterForeGround withObject:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application{
    [[PLController shared] addDebugLogsWithMsg:@"杀掉程序 调用 unregisterAccountsWithRemovePushNotification"];
    
    //挂断电话
    [[PLController shared] hangupAll];
    
    //注销账户
    [[PLController shared] unregisterAccountsWithRemovePushNotification:false];
    
    //Uninitialize
    [[PLController shared] Uninitialize];
    
    [PDRCore destoryEngine];
}

#pragma mark -
#pragma mark URL

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    [self application:application handleOpenURL:url];
    return YES;
}

/*
 * @Summary:程序被第三方调用，传入参数启动
 *
 */
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    [PDRCore handleSysEvent:PDRCoreSysEventOpenURL withObject:url];
    return YES;
}


/*
 * @Summary:远程push注册成功收到DeviceToken回调
 *
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"application--didRegisterForRemoteNotificationsWithDeviceToken[%@]", deviceToken);
    [PDRCore handleSysEvent:PDRCoreSysEventRevDeviceToken withObject:deviceToken];
}

/*
 * @Summary: 远程push注册失败
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [PDRCore handleSysEvent:PDRCoreSysEventRegRemoteNotificationsError withObject:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PDRCore handleSysEvent:PDRCoreSysEventRevRemoteNotification withObject:userInfo];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [self application:application didReceiveRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}


/*
 * @Summary:程序收到本地消息
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [PDRCore handleSysEvent:PDRCoreSysEventRevLocalNotification withObject:notification];
}


- (void)dealloc{
    [super dealloc];
}

@end

@implementation UINavigationController(Orient)

-(BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if([self.topViewController isKindOfClass:[ViewController class]])
        return [self.topViewController supportedInterfaceOrientations];
    return UIInterfaceOrientationMaskPortrait;
}

             

@end

