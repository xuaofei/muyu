//
//  LaunchChildManager.h
//  Taoism
//
//  Created by xuaofei on 2025/12/12.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LaunchChildManager : NSObject
+ (instancetype)shared;

- (void)launchSelfWithChildParameter;
- (void)exitChildProcess;
@end

NS_ASSUME_NONNULL_END
