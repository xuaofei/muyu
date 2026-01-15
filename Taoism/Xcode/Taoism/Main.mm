// Copyright © 2018 Unity Technologies. All rights reserved.
#import "define.h"
#import "AppDelegate.h"
#import "PathHelper.h"
#import <Cocoa/Cocoa.h>

int PlayerMain(int argc, const char *argv[]);

#if UNITY_ASAN
extern "C"
{
extern void unity_asan_configure();
}
#endif

static int gLockFD = -1;
// 托盘程序的单例控制
static BOOL AcquireSingleTrayInstanceLock(void) {
    NSString *bundleID = NSBundle.mainBundle.bundleIdentifier ?: @"app";
    NSString *lockPath = [[PathHelper appSupportDirPath]
                          stringByAppendingPathComponent:[bundleID stringByAppendingString:@".Traylock"]];
    gLockFD = open(lockPath.fileSystemRepresentation, O_CREAT | O_RDWR, 0600);
    if (gLockFD < 0) return YES;                 // 兜底：拿不到锁文件就继续跑
    return (flock(gLockFD, LOCK_EX | LOCK_NB) == 0);
}

// Unity程序的单例控制
static BOOL AcquireSingleUnityInstanceLock(void) {
    NSString *bundleID = NSBundle.mainBundle.bundleIdentifier ?: @"app";
    NSString *lockPath = [[PathHelper appSupportDirPath]
                          stringByAppendingPathComponent:[bundleID stringByAppendingString:@".Unitylock"]];
    gLockFD = open(lockPath.fileSystemRepresentation, O_CREAT | O_RDWR, 0600);
    if (gLockFD < 0) return YES;                 // 兜底：拿不到锁文件就继续跑
    return (flock(gLockFD, LOCK_EX | LOCK_NB) == 0);
}


BOOL isNeedLaunchChildProcess(void){
    NSString *path = [[PathHelper appSupportDirPath] stringByAppendingPathComponent:CHILD_PROCESS_KEY];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if(!data) {
        return NO;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    BOOL mode = [dic[@"mode"] isEqualToString:@"unity"];
    BOOL timeValid = [NSDate date].timeIntervalSince1970 - [dic[@"ts"] doubleValue] < 5;
    
    return mode && timeValid;
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
    
    NSLog(@"Taoism started:%d", getpid());
    NSLog(@"appSupportDirPath:%@", [PathHelper appSupportDirPath]);
    
    if (isNeedLaunchChildProcess()) {
        if (!AcquireSingleUnityInstanceLock()) {
            NSLog(@"AcquireSingleUnityInstanceLock process will exit");
            return 0;
        }
#if UNITY_ASAN
        unity_asan_configure();
#endif
        commamdQExit();
        
        // 4. 启动应用的主事件循环
        return PlayerMain(argc, argv);
    }
    
    if (!AcquireSingleTrayInstanceLock()) {
        NSLog(@"AcquireSingleTrayInstanceLock process will exit");
        return 0;
    }
    
    NSApplication *sharedApplication = [NSApplication sharedApplication];
    static AppDelegate *appDelegate = [[AppDelegate alloc] init];
    sharedApplication.delegate = appDelegate;
    [sharedApplication run];
    return 0;
}
