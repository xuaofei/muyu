//
//  AppDelegate.m
//  MuyuTray
//
//  Created by xuaofei on 2025/11/5.
//

#import "define.h"
#import "AppDelegate.h"
#import "TrayManager.h"
#import "TCPServer.h"
#import "LaunchChildManager.h"
#import "SystemThemeManager.h"
#import "ScreenManager.h"
#import "LaunchChildManager.h"
#import "LaunchAgentManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"启动OC TCP服务端...");
    
    [[TCPServer shared] startServerOnPort:NETWORK_PORT];
    [[TrayManager shared] showTray];
    [[LaunchChildManager shared] launchSelfWithChildParameter];
    
    [LaunchAgentManager addAppToLaunchAgents];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}
@end
