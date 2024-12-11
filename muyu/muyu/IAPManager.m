//
//  IAPManager.m
//  muyu
//
//  Created by xuaofei on 2024/12/11.
//

#import "IAPManager.h"

@interface IAPManager ()
@property (nonatomic, strong) SKProductsRequest *productsRequest;
@property (nonatomic, strong) NSArray<SKProduct *> *availableProducts;
@end

@implementation IAPManager

+ (instancetype)sharedManager {
    static IAPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[IAPManager alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:manager];
    });
    return manager;
}

- (void)fetchProductsWithIdentifiers:(NSArray<NSString *> *)productIdentifiers {
    NSSet *productSet = [NSSet setWithArray:productIdentifiers];
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.availableProducts = response.products;
    NSLog(@"可用商品: %@", self.availableProducts);
}

- (void)purchaseProduct:(SKProduct *)product {
    if ([SKPaymentQueue canMakePayments]) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        NSLog(@"用户无法进行支付");
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"交易成功");
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"交易失败");
                [self failTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"交易恢复");
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    // 验证收据并处理购买
}

- (void)failTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"支付失败: %@", transaction.error.localizedDescription);
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    // 恢复购买逻辑
}

@end
