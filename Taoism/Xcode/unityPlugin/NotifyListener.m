//
//  NotifyListener.m
//  unityPlugin
//
//  Created by xuaofei on 2025/11/7.
//

#import "NotifyListener.h"

#if defined (__cplusplus)
extern "C" {
#endif
    void StartNotifyListener() {
//        [[NotifyListener shared] startListener1];
    }
#if defined (__cplusplus)
}
#endif


@implementation NotifyListener
+ (instancetype)shared {
    static NotifyListener *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[NotifyListener alloc] init];
    });
    
    return ins;
}

- (void)startListener1 {
    NSLog(@"xaflog startListener1");
}

- (void)startListener {
    NSLog(@"xaflog startListener");
    
    // 获取默认的分布式通知中心
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];

    // 添加观察者，监听名为 "MyCustomNotification" 的通知
    [center addObserver: self
               selector: @selector(didReceiveNotification:)  // 收到通知时调用的方法
                   name: @"MyCustomNotification"  // 要监听的通知名称
                 object: nil];  // 如果为nil，则接收所有发送者发出的该通知；如果指定了object（如@"com.yourcompany.yourapp"），则只接收来自该特定发送者的通知。
}

// 接收到通知后的处理方法
- (void)didReceiveNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *message = userInfo[@"message"];
    if (message) {
        NSLog(@"收到通知，消息内容：%@", message);
        // 在此处处理通知逻辑，例如更新UI
    }
}
@end
