//
//  SetupManager.m
//  muyu
//
//  Created by xuaofei on 2024/12/7.
//

#import "SetupManager.h"
#import "Define.h"

@interface SetupManager ()
@property (assign, nonatomic) BOOL soundEnableCache;
@property (assign, nonatomic) BOOL vibrateEnableCache;
@property (assign, nonatomic) BOOL bubbleEnableCache;
@property (assign, nonatomic) BOOL showKnockTotalCache;
@end


@implementation SetupManager
+ (instancetype)sharedInstance {
    static SetupManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SetupManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.soundEnableCache = [[NSUserDefaults standardUserDefaults] boolForKey:SETUP_SOUND_ENABLE];
        
        self.vibrateEnableCache = [[NSUserDefaults standardUserDefaults] boolForKey:SETUP_VIBRATE_ENABLE];
        
        self.bubbleEnableCache = [[NSUserDefaults standardUserDefaults] boolForKey:SETUP_BUBBLE_ENABLE];
        
        self.showKnockTotalCache = [[NSUserDefaults standardUserDefaults] boolForKey:SETUP_SHOT_KNOCK_TOTAL_ENABLE];
    }
    
    return self;
}

- (void)setSoundEnable:(BOOL)enable {
    self.soundEnableCache = enable;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(enable) forKey:SETUP_SOUND_ENABLE];
}

- (BOOL)getSoundEnable {
    return self.soundEnableCache;
}

- (void)setVibrateEnable:(BOOL)enable {
    self.vibrateEnableCache = enable;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(enable) forKey:SETUP_VIBRATE_ENABLE];
}

- (BOOL)getVibrateEnable {
    return self.vibrateEnableCache;
}

- (void)setBubbleEnable:(BOOL)enable {
    self.bubbleEnableCache = enable;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(enable) forKey:SETUP_BUBBLE_ENABLE];
}

- (BOOL)getBubbleEnable {
    return self.bubbleEnableCache;
}

- (void)setShowKnockTotalEnable:(BOOL)enable {
    self.showKnockTotalCache = enable;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(enable) forKey:SETUP_SHOT_KNOCK_TOTAL_ENABLE];
}

- (BOOL)getShowKnockTotalEnable {
    return self.showKnockTotalCache;;
}
@end
