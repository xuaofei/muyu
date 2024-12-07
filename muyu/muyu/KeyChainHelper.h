//
//  KeyChainHelper.h
//  muyu
//
//  Created by xuaofei on 2024/12/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyChainHelper : NSObject
+ (void)saveToKeychainWithKey:(NSString *)key value:(NSString *)value;
+ (NSString *)readFromKeychainWithKey:(NSString *)key;
+ (void)deleteFromKeychainWithKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
