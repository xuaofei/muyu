//
//  TrayMsgMgr.h
//  Taoism
//
//  Created by xuaofei on 2026/1/27.
//  Copyright © 2026 Unity Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrayMsgMgr : NSObject
+ (instancetype)shared;

- (void)changeWindowSize:(NSInteger)windowSize;
- (void)processWillExit;
@end

NS_ASSUME_NONNULL_END
