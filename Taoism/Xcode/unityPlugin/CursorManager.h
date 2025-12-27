//
//  CursorManager.h
//  unityPlugin
//
//  Created by xuaofei on 2025/12/26.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CursorManager : NSObject
+ (instancetype)shared;

- (void)mouseUp;
- (void)mouseDown;

- (void)changeCursorSize;
@end

NS_ASSUME_NONNULL_END
