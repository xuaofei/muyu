//
//  SetupMgr.m
//  Taoism
//
//  Created by xuaofei on 2026/1/30.
//  Copyright © 2026 Unity Technologies. All rights reserved.
//

#import "define.h"
#import "SetupMgr.h"

@implementation SetupMgr
+ (instancetype)shared {
    static SetupMgr *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[SetupMgr alloc] init];
    });
    
    return ins;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupInit];
    }
    
    return self;
}

// 安装后第一次初始化配置
- (void)setupInit {
    // 先判断使用有配置
    BOOL fristSetupDidCompleted = [[NSUserDefaults standardUserDefaults] boolForKey:FRIST_SETUP_KEY];
    if (fristSetupDidCompleted) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FRIST_SETUP_KEY];
    
    // 默认大小：中
    [[NSUserDefaults standardUserDefaults] setInteger:WINDOW_SIZE_MEDIUM forKey:WINDOW_SIZE_KEY];
    // 默认开启声音
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:MUTE_KEY];
}

- (void)setWindowSize:(NSInteger)windowSize {
    [[NSUserDefaults standardUserDefaults] setInteger:windowSize forKey:WINDOW_SIZE_KEY];

}

- (NSInteger)getWindowSize {
    NSInteger windowSize = [[NSUserDefaults standardUserDefaults] integerForKey:WINDOW_SIZE_KEY];
    
    return windowSize;
}

// 是否静音
- (void)setMute:(BOOL)mute {
    [[NSUserDefaults standardUserDefaults] setBool:mute forKey:MUTE_KEY];
}

- (BOOL)getMute {
    return [[NSUserDefaults standardUserDefaults] boolForKey:MUTE_KEY];
}
@end
