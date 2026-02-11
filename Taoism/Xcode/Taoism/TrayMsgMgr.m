//
//  TrayMsgMgr.m
//  Taoism
//
//  Created by xuaofei on 2026/1/27.
//  Copyright © 2026 Unity Technologies. All rights reserved.
//

#import "define.h"
#import "TrayMsgMgr.h"
#import "SetupMgr.h"
@import MMWormhole;

@interface TrayMsgMgr ()
@property(nonatomic, retain) MMWormhole *wormhole;
@end

@implementation TrayMsgMgr
+ (instancetype)shared {
    static TrayMsgMgr *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[TrayMsgMgr alloc] init];
    });
    
    return ins;
}



- (instancetype)init {
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:APP_GROUP
                                                         optionalDirectory:@"wormhole"];
    
    [self.wormhole listenForMessageWithIdentifier:NOTIFY_PLUGIN_2_TRAY_MSG
                                         listener:^(id userInfo) {

        NSString *msg = [userInfo objectForKey:@"msg"];
        NSString *data = [userInfo objectForKey:@"data"];
        
        NSLog(@"xaflog msg:%@", msg);
        NSLog(@"xaflog data:%@", data);
        
        if ([msg isEqualToString:MSG_UNITY_START]) {
            NSInteger screenSize = [[NSUserDefaults standardUserDefaults] integerForKey:WINDOW_SIZE_KEY];
        
            [self changeWindowSize:screenSize];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BOOL mute = [[SetupMgr shared] getMute];
                [self setMute:mute];

            });
        }
    }];
    
    return self;
}

- (void)changeWindowSize:(NSInteger)windowSize {
    NSString *strWindowSize = [NSString stringWithFormat:@"%ld", windowSize];
    NSDictionary *data = @{@"msg":WINDOW_SIZE_KEY, @"data":strWindowSize};
    
    [self.wormhole passMessageObject:data identifier:NOTIFY_TRAY_2_PLUGON_MSG];
}

- (void)pray {
    NSDictionary *data = @{@"msg":PRAY_KEY, @"data":@""};
    [self.wormhole passMessageObject:data identifier:NOTIFY_TRAY_2_PLUGON_MSG];
}

- (void)exorcism {
    NSDictionary *data = @{@"msg":EXORCISM_KEY, @"data":@""};
    [self.wormhole passMessageObject:data identifier:NOTIFY_TRAY_2_PLUGON_MSG];
}

- (void)setMute:(BOOL)mute {
    NSDictionary *data = @{@"msg":MUTE_KEY, @"data":@(mute)};
    [self.wormhole passMessageObject:data identifier:NOTIFY_TRAY_2_PLUGON_MSG];
}

- (void)processWillExit {
    NSDictionary *data = @{@"msg":EXIT_SUB_APP_KEY, @"data":@""};
    
    [self.wormhole passMessageObject:data identifier:NOTIFY_TRAY_2_PLUGON_MSG];
}

@end
