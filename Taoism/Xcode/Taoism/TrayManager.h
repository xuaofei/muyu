//
//  TrayManager.h
//  Taoism
//
//  Created by xuaofei on 2025/11/12.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrayManager : NSObject
+(instancetype)shared;

-(void)showTray;
@end

NS_ASSUME_NONNULL_END
