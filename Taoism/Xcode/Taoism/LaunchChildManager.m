//
//  LaunchChildManager.m
//  Taoism
//

//  Created by xuaofei on 2025/12/12.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import "LaunchChildManager.h"
#import "define.h"
#import <AppKit/AppKit.h>

void processWillExit(void) {
    [[LaunchChildManager shared] exitChildProcess];
}


@interface LaunchChildManager()
@property(nonatomic, retain) NSRunningApplication *app;
@end

@implementation LaunchChildManager


+(instancetype)shared {
    static LaunchChildManager *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[LaunchChildManager alloc] init];
    });
    
    return ins;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        atexit(processWillExit);
    }
    
    return self;
}

- (void)launchSelfWithChildParameter {
    // 获取当前应用的路径
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    
    // 使用 NSWorkspace 启动新实例
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSURL *appURL = [NSURL fileURLWithPath:appPath];
    
    NSWorkspaceOpenConfiguration *config = [NSWorkspaceOpenConfiguration configuration];
    config.arguments = @[CHILD_PROCESS_KEY]; // 传递参数
    config.createsNewApplicationInstance = YES; // 创建新实例
    
    [workspace openApplicationAtURL:appURL
                      configuration:config
                  completionHandler:^(NSRunningApplication * _Nullable app, NSError * _Nullable error) {
        if (error) {
            NSLog(@"启动失败: %@", error.localizedDescription);
        } else {
            NSLog(@"新实例启动成功");
            self.app = app;
            
            [self.app addObserver:self
                  forKeyPath:@"isTerminated"
                     options:NSKeyValueObservingOptionNew
                     context:NULL]; // 上下文可用来区分不同的观察
        }
    }];
}

- (void)exitChildProcess {
    if (self.app) {
        [self.app terminate];
    }
}


// 实现 KVO 回调方法
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    // 检查被观察的对象和属性
    if (object == self.app && [keyPath isEqualToString:@"isTerminated"]) {
        BOOL isTerminated = [change[NSKeyValueChangeNewKey] boolValue];
        if (isTerminated) {
            NSLog(@"监控到应用程序已退出");
            // 在这里处理应用退出后的逻辑，例如清理资源、更新UI等

            // 重要：应用退出后，移除观察者，避免向已释放的观察者发送消息导致崩溃
            [object removeObserver:self forKeyPath:@"isTerminated"];
            self.app = nil;
            exit(0);
        }
    }
}

- (void)dealloc {
    if (self.app) {
        [self.app removeObserver:self forKeyPath:@"isTerminated"];
    }
}


@end
