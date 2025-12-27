//
//  ScreenManager.h
//  Taoism
//
//  Created by xuaofei on 2025/12/10.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#if defined (__cplusplus)
extern "C" {
#endif
    void StartScreenManager(void);
#if defined (__cplusplus)
}
#endif




@interface ScreenManager : NSObject
+ (instancetype)shared;
@end

NS_ASSUME_NONNULL_END
