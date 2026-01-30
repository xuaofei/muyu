//
//  SetupMgr.h
//  Taoism
//
//  Created by xuaofei on 2026/1/30.
//  Copyright © 2026 Unity Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SetupMgr : NSObject
+ (instancetype)shared;

// 窗口大小
- (void)setWindowSize:(NSInteger)windowSize;
- (NSInteger)getWindowSize;

// 是否静音
- (void)setMute:(BOOL)mute;
- (BOOL)getMute;
@end

NS_ASSUME_NONNULL_END
