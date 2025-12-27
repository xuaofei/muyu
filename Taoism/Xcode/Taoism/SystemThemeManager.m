//
//  SystemThemeManager.m
//  Taoism
//
//  Created by xuaofei on 2025/12/2.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import "SystemThemeManager.h"

@implementation SystemThemeManager

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static SystemThemeManager *ins = nil;
    dispatch_once(&onceToken, ^{
        ins = [[SystemThemeManager alloc] init];
    });
    
    return ins;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 注册监听系统主题变化通知
        [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                           selector: @selector(systemThemeChanged:)
                                                               name: @"AppleInterfaceThemeChangedNotification" // 系统主题变化通知名
                                                             object: nil];
    }
    return self;
}

- (void)systemThemeChanged:(NSNotification *)notification {
    NSLog(@"系统主题已改变");
    [self updateInterfaceForCurrentTheme];
}

- (void)updateInterfaceForCurrentTheme {
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey: @"AppleInterfaceStyle"];
    if (osxMode && [osxMode isEqualToString: @"Dark"]) {
        // 当前是深色模式
        NSLog(@"当前为深色模式");
        // 执行深色模式下的UI更新操作，例如更改窗口背景色、文字颜色等
        // self.window.backgroundColor = [NSColor windowBackgroundColor]; // 系统会自动适配的颜色
    } else {
        // 当前是浅色模式
        NSLog(@"当前为浅色模式");
        // 执行浅色模式下的UI更新操作
    }
}
@end
