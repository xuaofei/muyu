//
//  CursorManager.m
//  unityPlugin
//
//  Created by xuaofei on 2025/12/26.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import "define.h"
#import "CursorManager.h"
#import <AppKit/AppKit.h>
@interface CursorManager()
@property (nonatomic, strong) NSCursor *normalCursor;
@property (nonatomic, strong) NSCursor *pressedCursor;
@end


@implementation CursorManager
+ (void)load {
    //    CursorManager
}

+ (instancetype)shared {
    
    static CursorManager *ins = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[CursorManager alloc] init];
    });
    
    return ins;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self changeCursorSize];
    }
    
    return self;
}

- (void)mouseUp {
    [NSCursor pop];
    [self.normalCursor set];
    
    NSLog(@"xaflog mouseUp");
}

- (void)mouseDown {
    [self.pressedCursor push];
    
    NSLog(@"xaflog mouseDown");
}

- (void)changeCursorSize {
    NSArray<NSWindow *> *windows = [[NSApplication sharedApplication] windows];
    if (0 == windows.count) {
        return;
    }
    NSWindow *win = windows[0];
    
    int cursorUpWidth = 16;
    int cursorUpHeight = 62;
    int cursorDownWidth = 13;
    int cursorDownHeight = 72;
    NSImage *normalImage = [NSImage imageNamed:@"normal"];
    NSImage *pressedImage = [NSImage imageNamed:@"pressed"];
    
    if (CGRectGetWidth(win.frame) == SCREEN_SIZE_BIG) {
        cursorUpWidth = 16;
        cursorUpHeight = 62;
        cursorDownWidth = 13;
        cursorDownHeight = 72;
    } else if (CGRectGetWidth(win.frame) == SCREEN_SIZE_MEDIUM) {
        cursorUpWidth = 13;
        cursorUpHeight = 48;
        cursorDownWidth = 10;
        cursorDownHeight = 56;
    } else if (CGRectGetWidth(win.frame) == SCREEN_SIZE_SMALL) {
        cursorUpWidth = 9;
        cursorUpHeight = 34;
        cursorDownWidth = 7;
        cursorDownHeight = 38;
    }
    
    NSImage *currentNormalImage = [self resizedImage:normalImage toSize:NSMakeSize(cursorUpWidth, cursorUpHeight)];
    NSImage *currentPressedImage = [self resizedImage:pressedImage toSize:NSMakeSize(cursorDownWidth, cursorDownHeight)];
    
    NSPoint normalHotSpot = NSMakePoint(cursorUpWidth / 2, cursorUpHeight / 2);
    NSPoint pressedHotSpot = NSMakePoint(cursorDownWidth / 2, cursorDownHeight / 4);
    self.normalCursor = [[NSCursor alloc] initWithImage:currentNormalImage hotSpot:normalHotSpot];
    self.pressedCursor = [[NSCursor alloc] initWithImage:currentPressedImage hotSpot:pressedHotSpot];
    
    [self.normalCursor set];
}

- (NSImage *)resizedImage:(NSImage *)image toSize:(NSSize)newSize {
    NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
    [newImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [image drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
             fromRect:NSZeroRect
            operation:NSCompositingOperationSourceOver
             fraction:1.0];
    [newImage unlockFocus];
    return newImage;
}
@end
