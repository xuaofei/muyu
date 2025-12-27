//
//  LaunchAgentManager.h
//  Taoism
//
//  Created by xuaofei on 2025/12/21.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LaunchAgentManager : NSObject
/// 将当前应用添加到用户级启动项
+ (BOOL)addAppToLaunchAgents;

/// 从用户级启动项中移除当前应用
+ (BOOL)removeAppFromLaunchAgents;
@end

NS_ASSUME_NONNULL_END
