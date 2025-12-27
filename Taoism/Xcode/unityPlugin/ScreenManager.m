//
//  ScreenManager.m
//  Taoism
//
//  Created by xuaofei on 2025/12/10.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import "define.h"
#import "ScreenManager.h"
#import "CursorManager.h"
#import <AppKit/AppKit.h>

#if defined (__cplusplus)
extern "C" {
#endif
    void StartScreenManager(void) {
        [ScreenManager shared];
//        NSLog(@"xaflog call StartScreenManager");
    }
#if defined (__cplusplus)
}
#endif



@implementation ScreenManager
+ (instancetype)shared {
    static ScreenManager *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[ScreenManager alloc] init];
    });
    
    return ins;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(unityReceivedNotification:)
                       name:NOTIFY_UNITY_MSG
                     object:nil];
        
        
        
        
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        // 监听屏幕连接通知
        [notificationCenter addObserver:self
                               selector:@selector(screenDidConnect:)
                                   name:NSApplicationDidChangeScreenParametersNotification
                                 object:nil];
        // 应用到了新屏幕
        [notificationCenter addObserver:self
                               selector:@selector(WindowDidChangeScreen:)
                                   name:NSWindowDidChangeScreenNotification
                                 object:nil];
        
        [notificationCenter addObserver:self
                               selector:@selector(applicationDidFinishLaunching:)
                                   name:NSApplicationDidFinishLaunchingNotification
                                 object:nil];
        
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self WindowDidChangeScreen:nil];
            
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:NOTIFY_OC_MSG object:nil userInfo:@{@"msg":MSG_UNITY_START, @"data":@""} deliverImmediately:YES];
        });
        
        //        [self enumScreen];
    };
    
    return self;
}

- (void)screenDidConnect:(NSNotification *)notification {
    NSLog(@"xaflog screenDidConnect");
    //    [self enumScreen];
}

- (void)WindowDidChangeScreen:(NSNotification *)notification {
    NSLog(@"xaflog WindowDidChangeScreen");
    [self enumScreen];
    
    NSApplication *sharedApplication = [NSApplication sharedApplication];
    id dele = sharedApplication.delegate;
    NSWindow *keyWindow = [NSApplication sharedApplication].keyWindow;
    NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
    NSArray<NSWindow *> *windows = [[NSApplication sharedApplication] windows];
    if (windows.count) {
        NSScreen *screen = windows[0].screen;
        
        NSLog(@"xaflog WindowDidChangeScreen:%f", screen.backingScaleFactor);
        if (screen.backingScaleFactor) {
            NSString *backingScaleFactor = [NSString stringWithFormat:@"%f", screen.backingScaleFactor];
            NSDictionary *data = @{@"backingScaleFactor":backingScaleFactor};
            
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:NOTIFY_WINDOWS_SCREEN_CHANGED object:nil userInfo:data];
        }
    }
    //    NSScreen *screen = [[NSApplication sharedApplication] keyWindow].screen;
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSLog(@"xaflog applicationDidFinishLaunching");
}

- (void)unityReceivedNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *msg = [userInfo objectForKey:@"msg"];
    NSString *data = [userInfo objectForKey:@"data"];
    
    NSLog(@"xaflog unityReceivedNotification msg:%@", msg);
    NSLog(@"xaflog unityReceivedNotification data:%@", data);
    
    if ([msg isEqualToString:SCREEN_SIZE_KEY]) {
        NSInteger screenSize = [data integerValue];
        
        NSArray<NSWindow *> *windows = [[NSApplication sharedApplication] windows];
        if (windows.count) {
//            NSScreen *screen = windows[0].screen;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resizeWindow:windows[0] toSize:CGSizeMake(screenSize, screenSize)];
                [[CursorManager shared] changeCursorSize];
            });
        }
    }
    
}

// 假设 window 是你需要调整的 NSWindow 实例
- (void)resizeWindow:(NSWindow *)window toSize:(NSSize)newSize {
    NSLog(@"xaflog resizeWindow:%@ size:%@", window, NSStringFromSize(newSize));
    
    // 1. 获取窗口当前的框架矩形（包含标题栏）
    NSRect oldFrame = window.frame;
    
    // 2. 计算新旧尺寸的差值
    CGFloat deltaWidth = newSize.width - oldFrame.size.width;
    CGFloat deltaHeight = newSize.height - oldFrame.size.height;
    
    // 3. 计算新的原点坐标：向左移动宽度差值的一半，向下移动高度差值的一半
    //    这样窗口的中心点就能保持不变
    NSRect newFrame = oldFrame;
    newFrame.origin.x -= deltaWidth / 2.0;  // 向左调整X原点
    newFrame.origin.y -= deltaHeight / 2.0; // 向下调整Y原点
    newFrame.size = newSize;                // 应用新的尺寸
    
    // 4. 使用动画效果设置新的窗口框架，使调整更平滑
    [window setFrame:newFrame display:YES animate:YES];
}


- (void)enumScreen {
    // 获取所有屏幕的数组
    NSArray<NSScreen *> *allScreens = [NSScreen screens];
    NSLog(@"系统中共有 %lu 个屏幕", (unsigned long)allScreens.count);
    
    // 遍历所有屏幕
    [allScreens enumerateObjectsUsingBlock:^(NSScreen * _Nonnull screen, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRect frame = screen.frame;
        CGFloat scale = screen.backingScaleFactor;
        NSRect backingBounds = [screen convertRectToBacking: screen.frame];
        
        NSLog(@"xaflog 111");
        NSLog(@"xaflog  屏幕 %lu:", (unsigned long)idx);
        NSLog(@"xaflog  位置与尺寸 (逻辑坐标): %@", NSStringFromRect(frame));
        NSLog(@"xaflog  缩放比例: %.1f", scale);
        NSLog(@"xaflog  物理分辨率: %.0f x %.0f", backingBounds.size.width, backingBounds.size.height);
        
        // 判断是否是主屏幕（通常菜单栏所在的屏幕）
        if (screen == [NSScreen mainScreen]) {
            NSLog(@"  这是主屏幕");
        }
    }];
}

- (void)windowChangeScreen {
    NSWindow *keyWindow = [[NSApplication sharedApplication] keyWindow];
    NSScreen *screen = [[NSApplication sharedApplication] keyWindow].screen;
    
    NSLog(@"xaflog windowChangeScreen:%f", screen.backingScaleFactor);
    if (screen.backingScaleFactor) {
        NSString *backingScaleFactor = [NSString stringWithFormat:@"%f", screen.backingScaleFactor];
        NSDictionary *data = @{@"backingScaleFactor":backingScaleFactor};
        
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:NOTIFY_WINDOWS_SCREEN_CHANGED object:nil userInfo:data];
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_WINDOWS_SCREEN_CHANGED object:data];
        
    }
    
    
}
@end
