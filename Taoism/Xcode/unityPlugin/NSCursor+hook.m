//
//  NSCursor+hook.m
//  unityPlugin
//
//  Created by xuaofei on 2025/12/29.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import "define.h"
#import "NSCursor+hook.h"
#import "JRSwizzle.h"
//#import "CursorManager.h"

@implementation NSCursor(hook)

BOOL isChildProcess1() {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSArray *arguments = [processInfo arguments];
    
    if (arguments.count >= 2) {
        NSString *param = arguments[1];
        if ([param isEqualToString:CHILD_PROCESS_KEY]) {
            return YES;
        }
    }
    
    return NO;
}

+ (void)load {
    NSError* error = nil;
    [NSClassFromString(@"NSCursor") jr_swizzleMethod:@selector(set)
                                          withMethod:@selector(hook_set)
                                               error:&error];
    
    [NSClassFromString(@"NSCursor") jr_swizzleMethod:@selector(pop)
                                          withMethod:@selector(hook_pop)
                                               error:&error];
    
    [NSClassFromString(@"NSCursor") jr_swizzleMethod:@selector(push)
                                          withMethod:@selector(hook_push)
                                               error:&error];

}


- (void)hook_set {
    if (!isChildProcess1()) {
        NSLog(@"xaflog main hook_set");
        return [[NSCursor arrowCursor] hook_set];
    }
    
    NSLog(@"xaflog hook_set:%@", self.image);
    if ([self isEqualTo:[NSCursor arrowCursor]]) {
        NSLog(@"xaflog arrowCursor");
//        return [[CursorManager shared] mouseUp];
        
        NSImage *normalImage = [NSImage imageNamed:@"normal"];
        NSImage *pressedImage = [NSImage imageNamed:@"pressed"];
        
        int cursorUpWidth = 16;
        int cursorUpHeight = 62;
        int cursorDownWidth = 13;
        int cursorDownHeight = 72;
        NSPoint normalHotSpot = NSMakePoint(cursorUpWidth / 2, cursorUpHeight / 2);
        
        NSCursor *normalCursor = [[NSCursor alloc] initWithImage:normalImage hotSpot:normalHotSpot];
        return [normalCursor hook_set];
    }
    
    
    return [self hook_set];
}

- (void)hook_pop {
    if (!isChildProcess1()) {
        NSLog(@"xaflog main hook_pop");
        return [[NSCursor arrowCursor] hook_pop];
    }
    
    NSLog(@"xaflog hook_pop:%@", self.image);
    if ([self isEqualTo:[NSCursor arrowCursor]]) {
        NSLog(@"xaflog arrowCursor");
//        return [[CursorManager shared] mouseUp];
        
        NSImage *normalImage = [NSImage imageNamed:@"normal"];
        NSImage *pressedImage = [NSImage imageNamed:@"pressed"];
        
        int cursorUpWidth = 16;
        int cursorUpHeight = 62;
        int cursorDownWidth = 13;
        int cursorDownHeight = 72;
        NSPoint normalHotSpot = NSMakePoint(cursorUpWidth / 2, cursorUpHeight / 2);
        
        NSCursor *normalCursor = [[NSCursor alloc] initWithImage:normalImage hotSpot:normalHotSpot];
        return [normalCursor hook_pop];
    }
    
    
    return [self hook_pop];
}

- (void)hook_push {
    NSLog(@"xaflog main hook_push");
    return [self hook_push];
}
@end
