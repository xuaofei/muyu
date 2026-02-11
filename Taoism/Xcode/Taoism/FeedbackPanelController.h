//
//  FeedbackPanelController.h
//  Taoism
//
//  Created by xuaofei on 2026/2/11.
//  Copyright © 2026 Unity Technologies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface FeedbackPanelController : NSWindowController
+ (instancetype)shared;
- (void)show;
@end


NS_ASSUME_NONNULL_END
