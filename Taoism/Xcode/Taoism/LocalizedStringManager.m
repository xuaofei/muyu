//
//  LocalizedStringManager.m
//  Taoism
//
//  Created by xuaofei on 2026/1/21.
//  Copyright © 2026 Unity Technologies. All rights reserved.
//

#import "LocalizedStringManager.h"

@implementation LocalizedStringManager
+(instancetype)shared {
    static dispatch_once_t onceToken;
    static LocalizedStringManager *ins = nil;
    dispatch_once(&onceToken, ^{
        ins = [[LocalizedStringManager alloc] init];
    });
    
    return ins;
}

+(NSString*)localizedStringForKey:(NSString*)key {
    return NSLocalizedString(key, nil);
}
@end
