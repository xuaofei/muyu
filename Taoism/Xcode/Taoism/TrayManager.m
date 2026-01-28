//
//  TrayManager.m
//  Taoism
//
//  Created by xuaofei on 2025/11/12.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import "define.h"
#import "TrayManager.h"
#import "TrayMsgMgr.h"
#import "LaunchChildManager.h"
#import "LocalizedStringManager.h"
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface TrayManager()
@property(nonatomic, retain) NSStatusItem *statusItem;
@property(nonatomic, assign) float backingScaleFactor;

@property(nonatomic, retain) NSString *smallTitle;
@property(nonatomic, retain) NSString *mediumTitle;
@property(nonatomic, retain) NSString *largeTitle;
@property(nonatomic, retain) NSString *smallSelectTitle;
@property(nonatomic, retain) NSString *mediumSelectTitle;
@property(nonatomic, retain) NSString *largeSelectTitle;
@property(nonatomic, retain) NSString *exitTitle;

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
        self.smallTitle = [LocalizedStringManager localizedStringForKey:@"tray_screen_size_small_title"];
        self.mediumTitle = [LocalizedStringManager localizedStringForKey:@"tray_screen_size_medium_title"];
        self.largeTitle = [LocalizedStringManager localizedStringForKey:@"tray_screen_size_large_title"];
        self.smallSelectTitle = [LocalizedStringManager localizedStringForKey:@"tray_screen_size_small_select_title"];
        self.mediumSelectTitle = [LocalizedStringManager localizedStringForKey:@"tray_screen_size_medium_select_title"];
        self.largeSelectTitle = [LocalizedStringManager localizedStringForKey:@"tray_screen_size_large_select_title"];
        self.exitTitle = [LocalizedStringManager localizedStringForKey:@"tray_exit_title"];
        
        // 设置默认大小
        NSInteger screenSize = [[NSUserDefaults standardUserDefaults] integerForKey:WINDOW_SIZE_KEY];
        if (0 == screenSize) {
            [[NSUserDefaults standardUserDefaults] setInteger:WINDOW_SIZE_MEDIUM forKey:WINDOW_SIZE_KEY];
        }

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
    
    NSMenuItem *menuItemSmall = [menu addItemWithTitle:self.smallTitle action: @selector(toSmallSize:) keyEquivalent: @""];
    menuItemSmall.target = self;
    
    
    NSMenuItem *menuItemMedium = [menu addItemWithTitle:self.mediumTitle action: @selector(toMediumSize:) keyEquivalent: @""];
    menuItemMedium.target = self;
    
    
    NSMenuItem *menuItemBig = [menu addItemWithTitle:self.largeTitle action: @selector(toBigSize:) keyEquivalent: @""];
    menuItemBig.target = self;
    
    [menu addItem: [NSMenuItem separatorItem]]; // 添加一个分割线
    NSMenuItem *menuItemExit = [menu addItemWithTitle:self.exitTitle action: @selector(quit:) keyEquivalent: @""];
    menuItemExit.target = self;
    
    NSInteger screenSize = [[NSUserDefaults standardUserDefaults] integerForKey:WINDOW_SIZE_KEY];
    
    if (screenSize == WINDOW_SIZE_SMALL) {
        menuItemSmall.title = self.smallSelectTitle;
        menuItemMedium.title = self.mediumTitle;
        menuItemBig.title = self.largeTitle;
        
    } else if (screenSize == WINDOW_SIZE_MEDIUM) {
        menuItemSmall.title = self.smallTitle;
        menuItemMedium.title = self.mediumSelectTitle;
        menuItemBig.title = self.largeTitle;
        
    } else if (screenSize == WINDOW_SIZE_BIG) {
        menuItemSmall.title = self.smallTitle;
        menuItemMedium.title = self.mediumTitle;
        menuItemBig.title = self.largeSelectTitle;
    }
    self.statusItem.menu = menu;
}

- (void)toSmallSize:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:WINDOW_SIZE_SMALL forKey:WINDOW_SIZE_KEY];
    
    NSMenuItem *menuItemSmall = self.statusItem.menu.itemArray[0];
    NSMenuItem *menuItemMedium = self.statusItem.menu.itemArray[1];
    NSMenuItem *menuItemBig = self.statusItem.menu.itemArray[2];
    
    menuItemSmall.title = self.smallSelectTitle;
    menuItemMedium.title = self.mediumTitle;
    menuItemBig.title = self.largeTitle;
    
    [self changeScreenSize:WINDOW_SIZE_SMALL];
}

- (void)toMediumSize:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:WINDOW_SIZE_MEDIUM forKey:WINDOW_SIZE_KEY];
    
    NSMenuItem *menuItemSmall = self.statusItem.menu.itemArray[0];
    NSMenuItem *menuItemMedium = self.statusItem.menu.itemArray[1];
    NSMenuItem *menuItemBig = self.statusItem.menu.itemArray[2];
    
    menuItemSmall.title = self.smallTitle;
    menuItemMedium.title = self.mediumSelectTitle;
    menuItemBig.title = self.largeTitle;
    
    [self changeScreenSize:WINDOW_SIZE_MEDIUM];
}

- (void)toBigSize:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:WINDOW_SIZE_BIG forKey:WINDOW_SIZE_KEY];
    
    NSMenuItem *menuItemSmall = self.statusItem.menu.itemArray[0];
    NSMenuItem *menuItemMedium = self.statusItem.menu.itemArray[1];
    NSMenuItem *menuItemBig = self.statusItem.menu.itemArray[2];
    
    menuItemSmall.title = self.smallTitle;
    menuItemMedium.title = self.mediumTitle;
    menuItemBig.title = self.largeSelectTitle;
    
    [self changeScreenSize:WINDOW_SIZE_BIG];
}

- (void)quit:(id)sender
{
    exit(0);
}

- (void)changeScreenSize:(NSInteger)windowSize
{
    NSLog(@"changeScreenSize:%ld", windowSize);
    if (windowSize > WINDOW_SIZE_BIG || windowSize < WINDOW_SIZE_SMALL) {
        return;
    }
    
    [[TrayMsgMgr shared] changeWindowSize:windowSize];
    return;
}
@end
