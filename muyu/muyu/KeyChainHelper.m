//
//  KeyChainHelper.m
//  muyu
//
//  Created by xuaofei on 2024/12/7.
//

#import "KeyChainHelper.h"
#import "ViewController.h"
#import <Security/Security.h>

@implementation KeyChainHelper

// 保存数据到 Keychain
+ (void)saveToKeychainWithKey:(NSString *)key value:(NSString *)value {
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    
    // 删除可能存在的旧数据
    [self deleteFromKeychainWithKey:key];
    
    // 创建存储查询
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecValueData: valueData
    };
    
    // 添加到 Keychain
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    if (status == errSecSuccess) {
        NSLog(@"Data saved to Keychain successfully.");
    } else {
        NSLog(@"Failed to save data to Keychain. Error code: %d", (int)status);
    }
}

// 从 Keychain 读取数据
+ (NSString *)readFromKeychainWithKey:(NSString *)key {
    // 创建查询
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecReturnData: @YES,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
    };
    
    // 获取数据
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess) {
        NSData *retrievedData = (__bridge_transfer NSData *)result;
        NSString *retrievedString = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];
        return retrievedString;
    } else {
        NSLog(@"Failed to read data from Keychain. Error code: %d", (int)status);
        return nil;
    }
}

// 从 Keychain 删除数据（可选）
+ (void)deleteFromKeychainWithKey:(NSString *)key {
    // 创建查询
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: key
    };
    
    // 删除数据
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status == errSecSuccess) {
        NSLog(@"Data deleted from Keychain successfully.");
    } else {
        NSLog(@"Failed to delete data from Keychain. Error code: %d", (int)status);
    }
}
@end
