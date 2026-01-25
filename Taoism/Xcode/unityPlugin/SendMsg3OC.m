//
//  SendMsg3OC.m
//  unityPlugin
//
//  Created by xuaofei on 2025/12/26.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import "SendMsg3OC.h"
#import "CursorManager.h"
#import "ScreenManager.h"
#import "NSView+hook.h"

#if defined (__cplusplus)
extern "C" {
#endif
    void UnityStartd(void) {
        [ScreenManager shared];
        [CursorManager shared];
    }
    
    void MouseUp(void) {
        //[[CursorManager shared] mouseUp];
    }
    
    void MouseDown(void){
        //[[CursorManager shared] mouseDown];
    }

#if defined (__cplusplus)
}
#endif
