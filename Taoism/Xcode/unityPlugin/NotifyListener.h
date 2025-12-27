//
//  NotifyListener.h
//  unityPlugin
//
//  Created by xuaofei on 2025/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#if defined (__cplusplus)
extern "C" {
#endif

void StartNotifyListener();

#if defined (__cplusplus)
}
#endif

@interface NotifyListener : NSObject
+ (instancetype)shared;

- (void)startListener;
- (void)startListener1;
@end

NS_ASSUME_NONNULL_END
