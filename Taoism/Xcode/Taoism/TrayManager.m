//
//  TrayManager.m
//  Taoism
//
//  Created by xuaofei on 2025/11/12.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import "define.h"
#import "TrayManager.h"
#import "TCPServer.h"
#import "LaunchChildManager.h"
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
@import MMWormhole;

@interface TrayManager()
@property(nonatomic, retain) NSStatusItem *statusItem;
@property(nonatomic, assign) float backingScaleFactor;

@property(nonatomic, retain) MMWormhole *wormhole;
@end

@implementation TrayManager
+(instancetype)shared {
    
    static TrayManager *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[TrayManager alloc] init];
    });
    
    return ins;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:APP_GROUP
                                                             optionalDirectory:@"wormhole"];
        
        // 设置默认大小
        NSInteger screenSize = [[NSUserDefaults standardUserDefaults] integerForKey:SCREEN_SIZE_KEY];
        if (0 == screenSize) {
            [[NSUserDefaults standardUserDefaults] setInteger:SCREEN_SIZE_MEDIUM forKey:SCREEN_SIZE_KEY];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clientConnectNetwork) name:NOTIFY_CLIENT_CONNECT_NETWORK object:nil];
        
        [self.wormhole listenForMessageWithIdentifier:NOTIFY_WINDOWS_SCREEN_CHANGED
                                             listener:^(id userInfo) {
            NSInteger screenSize = [[NSUserDefaults standardUserDefaults] integerForKey:SCREEN_SIZE_KEY];
            
            
//            NSLog(@"收到分布式通知: %@", notification.name);
//            NSDictionary *userInfo = notification.userInfo;
            NSString *backingScaleFactor = userInfo[@"backingScaleFactor"];
            self.backingScaleFactor = [backingScaleFactor floatValue];
            
            if (self.backingScaleFactor == 1.0) {
                NSLog(@"附加信息: %@", userInfo);
                screenSize /= 2;
            }
            
            [[TrayManager shared] changeScreenSize:screenSize];
        }];
        
        [self.wormhole listenForMessageWithIdentifier:NOTIFY_UNITY_2_OC_MSG
                                             listener:^(id userInfo) {

            NSString *msg = [userInfo objectForKey:@"msg"];
            NSString *data = [userInfo objectForKey:@"data"];
            
            NSLog(@"xaflog msg:%@", msg);
            NSLog(@"xaflog data:%@", data);
            
            if ([msg isEqualToString:MSG_UNITY_START]) {
                NSInteger screenSize = [[NSUserDefaults standardUserDefaults] integerForKey:SCREEN_SIZE_KEY];
                
                NSString *strScreenSize = [NSString stringWithFormat:@"%ld", screenSize];
                
                
                NSDictionary *data = @{@"msg":SCREEN_SIZE_KEY, @"data":strScreenSize};
                [self.wormhole passMessageObject:data identifier:NOTIFY_OC_2_UNITY_MSG];
            }
        }];
    }
    
    return self;
}

-(void)showTray
{
    // 获取系统状态栏并创建状态项
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength: NSSquareStatusItemLength];
    
    // 设置图标（图片尺寸需合适，状态栏高度为22点）
    NSImage *image = [NSImage imageNamed:@"muyuTray_white"]; // 替换为你的图片名称
    image.template = YES;
    [self.statusItem.button setImage:image];
    
    // 设置点击时有高亮效果
    if (self.statusItem.button.cell) {
        [self.statusItem.button.cell setHighlightsBy:NSContentsCellMask];
    }
    
    // 设置鼠标悬停提示文字
    //    self.statusItem.button.toolTip = @"我的托盘应用";
    
    // 3. 创建菜单
    NSMenu *menu = [[NSMenu alloc] init];
    
    // 4. 向菜单中添加菜单项
    NSMenuItem *menuItemSmall = [menu addItemWithTitle:SCREEN_SIZE_SMALL_SELECT_TITLE action: @selector(toSmallSize:) keyEquivalent: @""];
    menuItemSmall.target = self;
    NSMenuItem *menuItemMedium = [menu addItemWithTitle:SCREEN_SIZE_MEDIUM_TITLE action: @selector(toMediumSize:) keyEquivalent: @""];
    menuItemMedium.target = self;
    NSMenuItem *menuItemBig = [menu addItemWithTitle:SCREEN_SIZE_BIG_TITLE action: @selector(toBigSize:) keyEquivalent: @""];
    menuItemBig.target = self;
    [menu addItem: [NSMenuItem separatorItem]]; // 添加一个分割线
    NSMenuItem *menuItemExit = [menu addItemWithTitle: @"退出" action: @selector(quit:) keyEquivalent: @""];
    menuItemExit.target = self;
    
    NSInteger screenSize = [[NSUserDefaults standardUserDefaults] integerForKey:SCREEN_SIZE_KEY];
    
    if (screenSize == SCREEN_SIZE_SMALL) {
        menuItemSmall.title = SCREEN_SIZE_SMALL_SELECT_TITLE;
        menuItemMedium.title = SCREEN_SIZE_MEDIUM_TITLE;
        menuItemBig.title = SCREEN_SIZE_BIG_TITLE;
        
    } else if (screenSize == SCREEN_SIZE_MEDIUM) {
        menuItemSmall.title = SCREEN_SIZE_SMALL_TITLE;
        menuItemMedium.title = SCREEN_SIZE_MEDIUM_SELECT_TITLE;
        menuItemBig.title = SCREEN_SIZE_BIG_TITLE;
        
    } else if (screenSize == SCREEN_SIZE_BIG) {
        menuItemSmall.title = SCREEN_SIZE_SMALL_TITLE;
        menuItemMedium.title = SCREEN_SIZE_MEDIUM_TITLE;
        menuItemBig.title = SCREEN_SIZE_BIG_SELECT_TITLE;
    }
    self.statusItem.menu = menu;
}

- (void)toSmallSize:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:SCREEN_SIZE_SMALL forKey:SCREEN_SIZE_KEY];
    
    NSMenuItem *menuItemSmall = self.statusItem.menu.itemArray[0];
    NSMenuItem *menuItemMedium = self.statusItem.menu.itemArray[1];
    NSMenuItem *menuItemBig = self.statusItem.menu.itemArray[2];
    
    menuItemSmall.title = SCREEN_SIZE_SMALL_SELECT_TITLE;
    menuItemMedium.title = SCREEN_SIZE_MEDIUM_TITLE;
    menuItemBig.title = SCREEN_SIZE_BIG_TITLE;
    
    [self changeScreenSize:SCREEN_SIZE_SMALL];
}

- (void)toMediumSize:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:SCREEN_SIZE_MEDIUM forKey:SCREEN_SIZE_KEY];
    
    NSMenuItem *menuItemSmall = self.statusItem.menu.itemArray[0];
    NSMenuItem *menuItemMedium = self.statusItem.menu.itemArray[1];
    NSMenuItem *menuItemBig = self.statusItem.menu.itemArray[2];
    
    menuItemSmall.title = SCREEN_SIZE_SMALL_TITLE;
    menuItemMedium.title = SCREEN_SIZE_MEDIUM_SELECT_TITLE;
    menuItemBig.title = SCREEN_SIZE_BIG_TITLE;
    
    [self changeScreenSize:SCREEN_SIZE_MEDIUM];
}

- (void)toBigSize:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:SCREEN_SIZE_BIG forKey:SCREEN_SIZE_KEY];
    
    NSMenuItem *menuItemSmall = self.statusItem.menu.itemArray[0];
    NSMenuItem *menuItemMedium = self.statusItem.menu.itemArray[1];
    NSMenuItem *menuItemBig = self.statusItem.menu.itemArray[2];
    
    menuItemSmall.title = SCREEN_SIZE_SMALL_TITLE;
    menuItemMedium.title = SCREEN_SIZE_MEDIUM_TITLE;
    menuItemBig.title = SCREEN_SIZE_BIG_SELECT_TITLE;
    
    [self changeScreenSize:SCREEN_SIZE_BIG];
}

- (void)quit:(id)sender
{
    exit(0);
}

- (void)changeScreenSize:(NSInteger)screenSize
{
    NSLog(@"changeScreenSize:%ld", screenSize);
    if (screenSize > SCREEN_SIZE_BIG || screenSize < SCREEN_SIZE_SMALL) {
        return;
    }
    
    [self sendMessage2Unity2:screenSize];
    return;
    
//    NSString *data = [NSString stringWithFormat:@"%ld", (long)screenSize];
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSDictionary *dic = @{@"version":@"1.0",
//                              @"screenSize":data};
//        
//        [self sendMessage2Unity:dic];
//    });
}

- (void)sendMessage2Unity:(NSDictionary*)data
{
    NSError *error;
    if (@available(macOS 10.15, *)) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                           options:NSJSONWritingWithoutEscapingSlashes
                                                             error:&error];
        
        // Check for errors during conversion
        if (jsonData) {
            // Convert the JSON data to an NSString
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"JSON output:\n%@", jsonString);
            
            
            [[TCPServer shared] sendMessage:jsonString];
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)sendMessage2Unity2:(NSInteger)screenSize {
    NSString *strScreenSize = [NSString stringWithFormat:@"%ld", screenSize];
    
    NSDictionary *data = @{@"msg":SCREEN_SIZE_KEY, @"data":strScreenSize};
    [self.wormhole passMessageObject:data identifier:NOTIFY_OC_2_UNITY_MSG];
}

- (void)myCustomQuitRoutine {
    exit(0);
}

- (void)clientConnectNetwork {
    NSLog(@"clientConnectNetwork");
    return;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger screenSize = [[NSUserDefaults standardUserDefaults] integerForKey:SCREEN_SIZE_KEY];
        
        NSScreen *screen = [[NSApplication sharedApplication] keyWindow].screen;
        //        self.backingScaleFactor = screen.backingScaleFactor;
        //        if (self.backingScaleFactor == 1.0) {
        //            screenSize /= 2;
        //        }
        
        [[TrayManager shared] changeScreenSize:screenSize];
    });
    
}
@end
