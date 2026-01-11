//
//  NSView+hook.m
//  unityPlugin
//
//  Created by xuaofei on 2025/12/28.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import "NSView+hook.h"
#import "JRSwizzle.h"
#import <objc/runtime.h>


@implementation NSView (_hook)
+ (void)load {
    NSError* error = nil;
    [NSClassFromString(@"NSView") jr_swizzleMethod:@selector(resetCursorRects)
                                        withMethod:@selector(hook_resetCursorRects)
                                             error:&error];
    
    [NSClassFromString(@"NSView") jr_swizzleMethod:@selector(discardCursorRects)
                                        withMethod:@selector(hook_discardCursorRects)
                                             error:&error];
    
    [NSClassFromString(@"NSView") jr_swizzleMethod:@selector(initWithFrame:)
                                        withMethod:@selector(hook_initWithFrame:)
                                             error:&error];
    
    [NSClassFromString(@"NSView") jr_swizzleMethod:@selector(initWithCoder:)
                                        withMethod:@selector(hook_initWithCoder:)
                                             error:&error];
    
    if (error) {
        NSLog(@"xaflog error:%@", error.description);
    }
}

- (instancetype)hook_initWithFrame:(NSRect)frameRect {
    id da = [self hook_initWithFrame:frameRect];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTrackingAreaOptions o=NSTrackingActiveInKeyWindow|NSTrackingInVisibleRect|NSTrackingCursorUpdate;
        [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:NSZeroRect options:o owner:self userInfo:nil]];
    });
    return da;
}

- (nullable instancetype)hook_initWithCoder:(NSCoder *)coder {
    id da = [self hook_initWithCoder:coder];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTrackingAreaOptions o=NSTrackingActiveInKeyWindow|NSTrackingInVisibleRect|NSTrackingCursorUpdate;
        [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:NSZeroRect options:o owner:self userInfo:nil]];
    });
    return da;
}
- (void)hook_discardCursorRects {
     return [self hook_discardCursorRects];
}

- (void)hook_resetCursorRects {
    [self hook_resetCursorRects];
    NSLog(@"xaflog hook_resetCursorRects");
    
    static NSCursor* normalCursor = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSImage *normalImage = [NSImage imageNamed:@"normal"];
        NSImage *pressedImage = [NSImage imageNamed:@"pressed"];
        
        int cursorUpWidth = 16;
        int cursorUpHeight = 62;
        int cursorDownWidth = 13;
        int cursorDownHeight = 72;
        NSPoint normalHotSpot = NSMakePoint(cursorUpWidth / 2, cursorUpHeight / 2);
        
        normalCursor = [[NSCursor alloc] initWithImage:normalImage hotSpot:normalHotSpot];
    });
    
//    NSLog(@"xaflog hook_resetCursorRects:%@ %@",self, normalCursor);
    [self addCursorRect:self.bounds cursor:normalCursor];
}
@end

