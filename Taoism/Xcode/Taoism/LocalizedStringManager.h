//
//  LocalizedStringManager.h
//  Taoism
//
//  Created by xuaofei on 2026/1/21.
//  Copyright © 2026 Unity Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalizedStringManager : NSObject
+(instancetype)shared;

+(NSString*)localizedStringForKey:(NSString*)key;
@end

NS_ASSUME_NONNULL_END
