//
//  NSWindow+Hook.m
//  unityPlugin
//
//  Created by xuaofei on 2025/12/28.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import "NSWindow+Hook.h"
#import "JRSwizzle.h"
#import <objc/runtime.h>

@implementation NSWindow(_Hook)
+ (void)load {
    NSLog(@"[hook] +load fired, PlayerWindow=%@ UnityPlayerWindow=%@",
          NSClassFromString(@"NSWindow"),
          NSClassFromString(@"UnityPlayerWindow"));
    
    NSError* error = nil;
    [NSClassFromString(@"NSWindow") jr_swizzleMethod:@selector(init)
                                              withMethod:@selector(hook_init)
                                                   error:&error];
    if (error) {
        NSLog(@"xaflog error:%@", error.description);
    }
    
    [NSClassFromString(@"NSWindow") jr_swizzleMethod:@selector(awakeFromNib)
                                              withMethod:@selector(hook_awakeFromNib)
                                                   error:&error];
    if (error) {
        NSLog(@"xaflog error:%@", error.description);
    }
    [NSClassFromString(@"NSWindow") jr_swizzleMethod:@selector(initWithCoder:)
                                              withMethod:@selector(hook_initWithCoder:)
                                                   error:&error];
    
    if (error) {
        NSLog(@"xaflog error:%@", error.description);
    }
    [NSClassFromString(@"NSWindow") jr_swizzleMethod:@selector(initWithContentRect:styleMask:backing:defer:)
                                              withMethod:@selector(hook_initWithContentRect:styleMask:backing:defer:)
                                                   error:&error];
    if (error) {
        NSLog(@"xaflog error:%@", error.description);
    }
    [NSClassFromString(@"NSWindow") jr_swizzleMethod:@selector(initWithContentRect:styleMask:backing:defer:screen:)
                                              withMethod:@selector(hook_initWithContentRect:styleMask:backing:defer:screen:)
                                                   error:&error];
    
    if (error) {
        NSLog(@"xaflog error:%@", error.description);
    }
    [NSClassFromString(@"NSWindow") jr_swizzleMethod:@selector(resetCursorRects)
                                              withMethod:@selector(hook_resetCursorRects)
                                                   error:&error];
    
    
    if (error) {
        NSLog(@"xaflog error:%@", error.description);
    }
    
    [NSClassFromString(@"NSWindow") jr_swizzleMethod:@selector(setFrame:display:)
                                              withMethod:@selector(hook_setFrame:display:)
                                                   error:&error];
    
    
    if (error) {
        NSLog(@"xaflog error:%@", error.description);
    }
    [NSClassFromString(@"NSWindow") jr_swizzleMethod:@selector(disableCursorRects)
                                              withMethod:@selector(hook_disableCursorRects)
                                                   error:&error];
    
    
    if (error) {
        NSLog(@"xaflog error:%@", error.description);
    }
    
    
    
    [NSClassFromString(@"NSWindow") jr_swizzleClassMethod:@selector(windowWithContentViewController:)
                                              withClassMethod:@selector(hook_windowWithContentViewController:)
                                                        error:&error];
    if (error) {
        NSLog(@"xaflog error:%@", error.description);
    }
}

+ (instancetype)hook_windowWithContentViewController:(NSViewController *)contentViewController {
    
    return [self hook_windowWithContentViewController:contentViewController];
}

- (instancetype)hook_init {
    return [self hook_init];
}

- (void)hook_awakeFromNib {
    return [self hook_awakeFromNib];
}

- (instancetype)hook_initWithCoder:(NSCoder *)coder {
    return [self hook_initWithCoder:coder];
}

- (instancetype)hook_initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    
    id dd =  [self hook_initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTrackingAreaOptions o=NSTrackingActiveInKeyWindow|NSTrackingInVisibleRect|NSTrackingCursorUpdate;
        [self.contentView addTrackingArea:[[NSTrackingArea alloc] initWithRect:NSZeroRect options:o owner:self userInfo:nil]];
    });

    
//    BOOL eye = self.areCursorRectsEnabled;
//    [self enableCursorRects];
    
    
    
//    NSImage *normalImage = [NSImage imageNamed:@"normal"];
//    NSImage *pressedImage = [NSImage imageNamed:@"pressed"];
//    
//    int cursorUpWidth = 16;
//    int cursorUpHeight = 62;
//    int cursorDownWidth = 13;
//    int cursorDownHeight = 72;
//    NSPoint normalHotSpot = NSMakePoint(cursorUpWidth / 2, cursorUpHeight / 2);
//    self.normalCursor = [[NSCursor alloc] initWithImage:normalImage hotSpot:normalHotSpot];
    
    return dd;
}

- (instancetype)hook_initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag screen:(nullable NSScreen *)screen {
    
    return [self hook_initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag screen:screen];
}

- (void)hook_resetCursorRects {
    
    
    [self hook_resetCursorRects];
    static NSCursor *normalCursor = nil;
    if (normalCursor == nil) {
        int cursorUpWidth = 16;
        int cursorUpHeight = 62;
        int cursorDownWidth = 13;
        int cursorDownHeight = 72;
        
        NSImage *normalImage = [NSImage imageNamed:@"normal"];
        
        NSPoint normalHotSpot = NSMakePoint(cursorUpWidth / 2, cursorUpHeight / 2);
        normalCursor = [[NSCursor alloc] initWithImage:normalImage hotSpot:normalHotSpot];
    }
    
    [self.contentView addCursorRect:self.contentView.bounds cursor:normalCursor];
}

- (void)hook_setFrame:(NSRect)frameRect display:(BOOL)flag {
    return [self hook_setFrame:frameRect display:flag];
}

- (void)hook_disableCursorRects {
    return [self hook_disableCursorRects];
}
@end
