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
@property (nonatomic, strong) NSCursor *normalCursor1;
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
//    NSArray<NSWindow *> *windows = [[NSApplication sharedApplication] windows];
//    if (0 == windows.count) {
//        return;
//    }
//    NSWindow *win = windows[0];
//    [win invalidateCursorRectsForView:win.contentView];

    
//    return;
//    [self.pressedCursor pop];
    [self.normalCursor set];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.normalCursor set];
//    });
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.normalCursor set];
//    });
    
    
    NSLog(@"xaflog mouseUp normalCursor");
}

- (void)mouseUp1 {
    [self.normalCursor1 set];
    NSLog(@"xaflog mouseUp normalCursor");
}

- (void)mouseDown {
//    return;
//    [self.normalCursor set];
    [self.pressedCursor set];
    
    NSLog(@"xaflog mouseDown pressedCursor");
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
    
    NSImage *currentNormalImage = [self resizedImage:normalImage toSize:NSMakeSize(cursorUpWidth/2, cursorUpHeight/2)];
    NSImage *currentPressedImage = [self resizedImage:pressedImage toSize:NSMakeSize(cursorDownWidth/2, cursorDownHeight/2)];
    
    {
        
        NSString *file = [NSString stringWithFormat:@"/tmp/normalImage_%d.png", (int)CGRectGetWidth(win.frame)];
        
        NSURL *url = [NSURL fileURLWithPath:file];
        NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithData:currentNormalImage.TIFFRepresentation];
        NSData *pngData = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        NSError *err = nil;
        BOOL ok = [pngData writeToURL:url options:NSDataWritingAtomic error:&err];
    }

    {
        NSString *file = [NSString stringWithFormat:@"/tmp/pressedImage_%d.png", (int)CGRectGetWidth(win.frame)];
        NSURL *url = [NSURL fileURLWithPath:file];
        NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithData:currentPressedImage.TIFFRepresentation];
        NSData *pngData = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        NSError *err = nil;
        BOOL ok = [pngData writeToURL:url options:NSDataWritingAtomic error:&err];
    }
    
    
    NSPoint normalHotSpot = NSMakePoint(cursorUpWidth / 2, cursorUpHeight / 2);
    NSPoint pressedHotSpot = NSMakePoint(cursorDownWidth / 2, cursorDownHeight / 4);
    self.normalCursor = [[NSCursor alloc] initWithImage:currentNormalImage hotSpot:normalHotSpot];
    self.normalCursor1 = [[NSCursor alloc] initWithImage:currentNormalImage hotSpot:pressedHotSpot];
    self.pressedCursor = [[NSCursor alloc] initWithImage:currentPressedImage hotSpot:pressedHotSpot];
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.normalCursor set];
    });
    
    NSLog(@"xaflog mouseUp normalCursor");
    
    NSLog(@"xaflog changeCursorSize");
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
