//
//  IAPManager.h
//  muyu
//
//  Created by xuaofei on 2024/12/11.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface IAPManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

// 单例方法
+ (instancetype)sharedManager;

// 开始请求商品信息
- (void)fetchProductsWithIdentifiers:(NSArray<NSString *> *)productIdentifiers;

// 购买商品
- (void)purchaseProduct:(SKProduct *)product;

@end
