//
//  DCSplashObserver.m
//  HBuilder
//
//  Created by Lin xinzheng on 2018/3/7.
//  Copyright © 2018年 DCloud. All rights reserved.
//

#import "DCSplashAdObserver.h"
#import "PDRCoreAppManager.h"
#import "DCADManager.h"


DCSplashAdObserver* g_splashObserver = NULL;

@interface DCSplashAdObserver () <DCH5ScreenAdvertisingDelegate>
@property (strong, nonatomic) DCH5ScreenAdvertising *adViewContoller;
@property (strong, nonatomic) DCADLaunch *ad;
@end

@implementation DCSplashAdObserver
   
    
+ (DCH5ScreenAdvertising*)splashAdViewController{
    DCADManager *adManager = [DCADManager adManager];
    UIViewController* adViewController = [adManager getADViewController];
    return adViewController;
}

#pragma mark - 开屏广告

- (void)onAppSplashClose:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:g_splashObserver name:PDRCoreAppDidLoadNotificationKey object:nil];
    [self.adViewContoller showSikeButton];
}

- (void)clickedAdverType:(EDCH5ADVType)type EventData:(NSString*)actData ExtData:(NSDictionary*)extDat ADLaunch:(DCADLaunch*)adLaunch {
    if ( type == EDCH5ADVType_url ) {
    } else if ( type == EDCH5ADVType_App  ){
    }
    [[DCADManager adManager] clickLaunchAD:adLaunch];
}

- (void)advScreenCanShow {
    [[DCADManager adManager] impLaunchAD:self.ad];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[PDRCore Instance] start];
    });
}

- (BOOL)advScreenWillClose:(EDCH5ADVCloseType)type {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDCSplashScreenCloseEvent object:nil];
    return YES;
}

@end
