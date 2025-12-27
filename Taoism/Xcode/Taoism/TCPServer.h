//
//  TCPServer.h
//  Taoism
//
//  Created by xuaofei on 2025/11/11.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCPServer : NSObject
+ (instancetype)shared;
- (void)startServerOnPort:(int)port;
- (void)stopServer;

- (void)sendMessage:(NSString*)msg;
@end

NS_ASSUME_NONNULL_END
