//
//  ReviewPrompter.h
//  Taoism
//
//  Created by xuaofei on 2026/3/1.
//  Copyright © 2026 Unity Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReviewPrompter : NSObject
+ (instancetype)shared;
- (void)maybePromptForReviewByDays;
@end

NS_ASSUME_NONNULL_END
