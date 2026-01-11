//
//  NSView+hook.h
//  unityPlugin
//
//  Created by xuaofei on 2025/12/28.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSView(_hook)

@end

void ACEnableGlobalCursor(NSCursor *cursor);

NS_ASSUME_NONNULL_END
