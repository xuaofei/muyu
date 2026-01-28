//
//  PluginMsgMgr.m
//  unityPlugin
//
//  Created by xuaofei on 2026/1/27.
//  Copyright © 2026 Unity Technologies. All rights reserved.
//

#import "define.h"
#import "PluginMsgMgr.h"
#import "ScreenManager.h"
@import MMWormhole;

@interface PluginMsgMgr ()
@property(nonatomic, retain) MMWormhole *wormhole;
@end

@implementation PluginMsgMgr
+ (instancetype)shared {
    static PluginMsgMgr *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[PluginMsgMgr alloc] init];
    });
    
    return ins;
}

- (instancetype)init {
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:APP_GROUP
                                                         optionalDirectory:@"wormhole"];
    [self.wormhole listenForMessageWithIdentifier:NOTIFY_TRAY_2_PLUGON_MSG
                                         listener:^(id userInfo) {
        NSString *msg = [userInfo objectForKey:@"msg"];
        NSLog(@"xaflog unityReceivedNotification msg:%@", msg);
        
        if ([msg isEqualToString:WINDOW_SIZE_KEY]) {
            NSString *data = [userInfo objectForKey:@"data"];
            NSLog(@"xaflog unityReceivedNotification data:%@", data);
            
            NSInteger screenSize = [data integerValue];
            [[ScreenManager shared] resizeWindow:CGSizeMake(screenSize, screenSize)];
            
        } else if ([msg isEqualToString:EXIT_SUB_APP_KEY]) {
            exit(0);
        }
    }];
    
    NSDictionary *data = @{@"msg":MSG_UNITY_START, @"data":@""};
    [self.wormhole passMessageObject:data identifier:NOTIFY_PLUGIN_2_TRAY_MSG];
    return self;
}
@end
