//
//  AppDelegate.m
//  MuyuTray
//
//  Created by xuaofei on 2025/11/5.
//

#import "define.h"
#import "AppDelegate.h"
#import "TrayManager.h"
#import "TrayMsgMgr.h"
#import "SetupMgr.h"
#import "LaunchChildManager.h"
#import "ScreenManager.h"
#import "LaunchChildManager.h"
#import "LaunchAgentManager.h"
#import "ReviewPrompter.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"启动OC TCP服务端...");
    
    [SetupMgr shared];
    [TrayMsgMgr shared];
    [[TrayManager shared] showTray];
    
    [[LaunchChildManager shared] launchSelfWithChildParameter];
    [LaunchAgentManager addAppToLaunchAgents];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ReviewPrompter shared] maybePromptForReviewByDays];
    });
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

// AppDelegate.m
- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls {
    for (NSURL *url in urls) {
        [self handleIncomingURL:url];
    }
}
- (void)handleIncomingURL:(NSURL *)url {
    NSURLComponents *c = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSString *action = c.host ?: @""; // 例如 myapp://open?token=xxx -> action=open
    if ([action containsString:@"childUnity"]) {
        
    }
    
//    NSString *token = nil;
//    for (NSURLQueryItem *item in c.queryItems) {
//        if ([item.name isEqualToString:@"token"]) { token = item.value; break; }
//    }
//    NSLog(@"action=%@ token=%@ url=%@", action, token, url.absoluteString);
//    // TODO: 根据 action/token 执行业务
}
@end
