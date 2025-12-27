// Copyright © 2018 Unity Technologies. All rights reserved.
#import "define.h"
#import "AppDelegate.h"
#import <Cocoa/Cocoa.h>

int PlayerMain(int argc, const char *argv[]);

#if UNITY_ASAN
extern "C"
{
extern void unity_asan_configure();
}
#endif



BOOL isChildProcess() {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSArray *arguments = [processInfo arguments];
    
    if (arguments.count >= 2) {
        NSString *param = arguments[1];
        if ([param isEqualToString:CHILD_PROCESS_KEY]) {
            return YES;
        }
    }
    
    return NO;
}

void commamdQExit() {
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * _Nullable(NSEvent * _Nonnull event) {
        // 检查是否同时按下了 Command 键和 Q 键
        if (([event modifierFlags] & NSEventModifierFlagCommand) && [event keyCode] == 12) { // keyCode 12 通常代表 Q 键
            exit(0);
            // 返回 nil 以阻止事件继续传递，从而取消退出
            return nil;
        }
        return event; // 对于其他按键，允许事件正常传递
    }];
}

int main(int argc, const char *argv[])
{
    // /Users/xuaofei/Library/Application Support/DefaultCompany/Taoism/logs/2025-12-20_000.log
    // 设置信号处理，确保程序退出时清理资源
    signal(SIGINT, SIG_DFL);
    signal(SIGTERM, SIG_DFL);
    
    if (isChildProcess()) {
#if UNITY_ASAN
        unity_asan_configure();
#endif
        commamdQExit();
        
        // 4. 启动应用的主事件循环
        return PlayerMain(argc, argv);
    }
    
    NSApplication *sharedApplication = [NSApplication sharedApplication];
    static AppDelegate *appDelegate = [[AppDelegate alloc] init];
    sharedApplication.delegate = appDelegate;
    [sharedApplication run];
    return 0;
}
