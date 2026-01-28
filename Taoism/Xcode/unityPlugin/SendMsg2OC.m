//
//  SendMsg2OC.m
//  unityPlugin
//
//  Created by xuaofei on 2025/12/26.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import "UnityPluginDefine.h"
#import "SendMsg2OC.h"
#import "ScreenManager.h"
#import "PluginMsgMgr.h"
#import "NSView+hook.h"


#if defined (__cplusplus)
extern "C" {
#endif
    // OC调用Unity
    UnityMsgCallback g_unityMsgCallback = NULL;
    void SetUnityMsgCallback(UnityMsgCallback cb) {
        g_unityMsgCallback = cb;
        NSLog(@"SetUnityMsgCallback");
    }
    
    void UnityStartd(void) {
        [ScreenManager shared];
        [PluginMsgMgr shared];
//        [CursorManager shared];
    }
    
    void MouseUp(void) {
        //        [[CursorManager shared] mouseUp];
    }
    
    void MouseDown(void){
        //        [[CursorManager shared] mouseDown];
    }
    
#if defined (__cplusplus)
}
#endif
