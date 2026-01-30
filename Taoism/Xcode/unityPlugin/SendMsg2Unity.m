//
//  SendMsg2Unity.m
//  unityPlugin
//
//  Created by xuaofei on 2026/1/27.
//  Copyright © 2026 Unity Technologies. All rights reserved.
//

#import "UnityPluginDefine.h"
#import "SendMsg2Unity.h"

extern UnityMsgCallback g_unityMsgCallback;

void BurnIncense(void) {
    if (!g_unityMsgCallback) {
        NSLog(@"unityMsgCallback is nil");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        g_unityMsgCallback("BurnIncense");
    });
}

void Mute(bool mute) {
    if (!g_unityMsgCallback) {
        NSLog(@"unityMsgCallback is nil");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (mute) {
            g_unityMsgCallback("Mute");
        } else {
            g_unityMsgCallback("Unmute");
        }
    });
}
