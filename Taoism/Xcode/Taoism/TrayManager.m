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
#import "SetupMgr.h"
#import "LaunchChildManager.h"
#import "LocalizedStringManager.h"
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface TrayManager()
@property(nonatomic, retain) NSStatusItem *statusItem;
@property(nonatomic, retain) NSMenu *sizeSubMenu;
@property(nonatomic, retain) NSMenuItem *menuItemMute;


@property(nonatomic, retain) NSString *prayTitle;
@property(nonatomic, retain) NSString *exorcismTitle;
@property(nonatomic, retain) NSString *smallTitle;
@property(nonatomic, retain) NSString *mediumTitle;
@property(nonatomic, retain) NSString *largeTitle;
@property(nonatomic, retain) NSString *smallSelectTitle;
@property(nonatomic, retain) NSString *mediumSelectTitle;
@property(nonatomic, retain) NSString *largeSelectTitle;
@property(nonatomic, retain) NSString *sizeTitle;
@property(nonatomic, retain) NSString *muteOffTitle;
@property(nonatomic, retain) NSString *muteOnTitle;
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
        self.prayTitle = [LocalizedStringManager localizedStringForKey:@"tray_pray_title"];
        self.exorcismTitle = [LocalizedStringManager localizedStringForKey:@"tray_exorcism_title"];
        self.smallTitle = [LocalizedStringManager localizedStringForKey:@"tray_screen_size_small_title"];
        self.mediumTitle = [LocalizedStringManager localizedStringForKey:@"tray_screen_size_medium_title"];
        self.largeTitle = [LocalizedStringManager localizedStringForKey:@"tray_screen_size_large_title"];
        self.smallSelectTitle = [LocalizedStringManager localizedStringForKey:@"tray_screen_size_small_select_title"];
        self.mediumSelectTitle = [LocalizedStringManager localizedStringForKey:@"tray_screen_size_medium_select_title"];
        self.largeSelectTitle = [LocalizedStringManager localizedStringForKey:@"tray_screen_size_large_select_title"];
        self.sizeTitle = [LocalizedStringManager localizedStringForKey:@"tray_size_title"];
        self.muteOffTitle = [LocalizedStringManager localizedStringForKey:@"tray_mute_off_title"];
        self.muteOnTitle = [LocalizedStringManager localizedStringForKey:@"tray_mute_on_title"];
        self.exitTitle = [LocalizedStringManager localizedStringForKey:@"tray_exit_title"];
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
    
    // 3. 创建菜单
    NSMenu *mainMenu = [[NSMenu alloc] init];
    // 一级菜单: 祈福
    NSMenuItem *menuItemPray = [[NSMenuItem alloc] initWithTitle:self.prayTitle action:@selector(toPray:) keyEquivalent:@""];
    [mainMenu addItem:menuItemPray];
    menuItemPray.target = self;
    
    // 一级菜单: 消灾
    NSMenuItem *menuItemExorcism = [[NSMenuItem alloc] initWithTitle:self.exorcismTitle action:@selector(toExorcism:) keyEquivalent:@""];
    [mainMenu addItem:menuItemExorcism];
    menuItemExorcism.target = self;
    
    [mainMenu addItem: [NSMenuItem separatorItem]]; 
    
    // 一级菜单: 尺寸
    NSMenuItem *menuItemSize = [[NSMenuItem alloc] initWithTitle:self.sizeTitle action:nil keyEquivalent:@""];
    [mainMenu addItem:menuItemSize];

    
    // 一级菜单: 音量
    BOOL mute = [[SetupMgr shared] getMute];
    self.menuItemMute = [[NSMenuItem alloc] initWithTitle:mute?self.muteOnTitle:self.muteOffTitle action:@selector(mute:) keyEquivalent:@""];
    [mainMenu addItem:self.menuItemMute];
    self.menuItemMute.target = self;
    
    // 关键：创建并设置二级菜单
    self.sizeSubMenu = [[NSMenu alloc] initWithTitle:@""];
    menuItemSize.submenu = self.sizeSubMenu;
    // 可选：避免被自动置灰
    menuItemSize.enabled = YES;
    
    NSMenuItem *menuItemSmall = [self.sizeSubMenu addItemWithTitle:self.smallTitle action: @selector(toSmallSize:) keyEquivalent: @""];
    menuItemSmall.target = self;
    
    
    NSMenuItem *menuItemMedium = [self.sizeSubMenu addItemWithTitle:self.mediumTitle action: @selector(toMediumSize:) keyEquivalent: @""];
    menuItemMedium.target = self;
    
    
    NSMenuItem *menuItemBig = [self.sizeSubMenu addItemWithTitle:self.largeTitle action: @selector(toBigSize:) keyEquivalent: @""];
    menuItemBig.target = self;
    
    [mainMenu addItem: [NSMenuItem separatorItem]]; // 添加一个分割线
    NSMenuItem *menuItemExit = [mainMenu addItemWithTitle:self.exitTitle action: @selector(quit:) keyEquivalent: @""];
    menuItemExit.target = self;
    
    NSInteger windowSize = [[SetupMgr shared] getWindowSize];
    
    if (windowSize == WINDOW_SIZE_SMALL) {
        menuItemSmall.title = self.smallSelectTitle;
        menuItemMedium.title = self.mediumTitle;
        menuItemBig.title = self.largeTitle;
        
    } else if (windowSize == WINDOW_SIZE_MEDIUM) {
        menuItemSmall.title = self.smallTitle;
        menuItemMedium.title = self.mediumSelectTitle;
        menuItemBig.title = self.largeTitle;
        
    } else if (windowSize == WINDOW_SIZE_BIG) {
        menuItemSmall.title = self.smallTitle;
        menuItemMedium.title = self.mediumTitle;
        menuItemBig.title = self.largeSelectTitle;
    }
    self.statusItem.menu = mainMenu;
}

// 祈福
- (void)toPray:(id)sender {
    [[TrayMsgMgr shared] pray];
}

// 消灾
- (void)toExorcism:(id)sender {
    [[TrayMsgMgr shared] exorcism];
}

// 开启/关闭音量
- (void)mute:(id)sender {
    BOOL mute = [[SetupMgr shared] getMute];
    mute = !mute;
    
    [[SetupMgr shared] setMute:mute];
    [[TrayMsgMgr shared] setMute:mute];
    
    self.menuItemMute.title = mute?self.muteOnTitle:self.muteOffTitle;
}

- (void)toSmallSize:(id)sender
{
    NSMenuItem *menuItemSmall = self.sizeSubMenu.itemArray[0];
    NSMenuItem *menuItemMedium = self.sizeSubMenu.itemArray[1];
    NSMenuItem *menuItemBig = self.sizeSubMenu.itemArray[2];
    
    menuItemSmall.title = self.smallSelectTitle;
    menuItemMedium.title = self.mediumTitle;
    menuItemBig.title = self.largeTitle;
    
    [self changeScreenSize:WINDOW_SIZE_SMALL];
}

- (void)toMediumSize:(id)sender
{
    NSMenuItem *menuItemSmall = self.sizeSubMenu.itemArray[0];
    NSMenuItem *menuItemMedium = self.sizeSubMenu.itemArray[1];
    NSMenuItem *menuItemBig = self.sizeSubMenu.itemArray[2];
    
    menuItemSmall.title = self.smallTitle;
    menuItemMedium.title = self.mediumSelectTitle;
    menuItemBig.title = self.largeTitle;
    
    [self changeScreenSize:WINDOW_SIZE_MEDIUM];
}

- (void)toBigSize:(id)sender
{
    NSMenuItem *menuItemSmall = self.sizeSubMenu.itemArray[0];
    NSMenuItem *menuItemMedium = self.sizeSubMenu.itemArray[1];
    NSMenuItem *menuItemBig = self.sizeSubMenu.itemArray[2];
    
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
    [[SetupMgr shared] setWindowSize:windowSize];
    
    if (windowSize > WINDOW_SIZE_BIG || windowSize < WINDOW_SIZE_SMALL) {
        return;
    }
    
    [[TrayMsgMgr shared] changeWindowSize:windowSize];
    return;
}
@end
