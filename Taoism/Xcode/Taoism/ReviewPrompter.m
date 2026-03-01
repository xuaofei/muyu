//
//  ReviewPrompter.m
//  Taoism
//
//  Created by xuaofei on 2026/3/1.
//  Copyright © 2026 Unity Technologies. All rights reserved.
//

#import "ReviewPrompter.h"
#import <AppKit/AppKit.h>
#import <StoreKit/StoreKit.h>

static NSString * const kFirstLaunchDateKey   = @"review.firstLaunchDate";
static NSString * const kLastAskDateKey       = @"review.lastAskDate";
static NSString * const kLastAskVersionKey    = @"review.lastAskVersion";
static NSString * const kUserOptOutKey        = @"review.userOptOut";

@implementation ReviewPrompter

+ (instancetype)shared {
    static ReviewPrompter *s;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [[ReviewPrompter alloc] init];
    });
    return s;
}

- (NSString *)currentVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"";
}

- (NSInteger)daysBetween:(NSDate *)from to:(NSDate *)to {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *startFrom = nil;
    NSDate *startTo = nil;
    [cal rangeOfUnit:NSCalendarUnitDay startDate:&startFrom interval:NULL forDate:from];
    [cal rangeOfUnit:NSCalendarUnitDay startDate:&startTo interval:NULL forDate:to];
    NSDateComponents *cmp = [cal components:NSCalendarUnitDay fromDate:startFrom toDate:startTo options:0];
    return cmp.day;
}

- (void)requestAppStoreReviewIfPossible {
    if (@available(macOS 10.14, *)) {
        [SKStoreReviewController requestReview];
    } else {
        // 低版本兜底：建议跳转到 App Store 评论页（你已有 openAppStoreReviewPage 可直接调用）
    }
}

- (void)maybePromptForReviewByDays {
    // 1) 必须在主线程/前台/有窗口时
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self maybePromptForReviewByDays];
        });
        return;
    }
    if (![NSApp isActive]) return;
    if (NSApp.keyWindow == nil) return;

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    // 2) 用户选择不再提示
    if ([ud boolForKey:kUserOptOutKey]) return;

    // 3) 记录首次使用日期
    NSDate *firstLaunch = [ud objectForKey:kFirstLaunchDateKey];
    if (!firstLaunch) {
        firstLaunch = [NSDate date];
        [ud setObject:firstLaunch forKey:kFirstLaunchDateKey];
        return; // 首次启动不弹
    }

    // 4) 按“使用天数”判断
    NSInteger minDays = 3; // 工具类推荐 3 或 7
    NSInteger daysUsed = [self daysBetween:firstLaunch to:[NSDate date]];
    if (daysUsed < minDays) return;

    // 5) 节流：每版本一次（或加上最短间隔）
    NSString *ver = [self currentVersion];
    NSString *lastVer = [ud stringForKey:kLastAskVersionKey];
    if ([lastVer isEqualToString:ver]) return;

    NSDate *lastAsk = [ud objectForKey:kLastAskDateKey];
    if (lastAsk) {
        NSInteger minIntervalDays = 90; // 更稳妥；如果你想“以后再说=14天后再问”，可做更细分
        if ([self daysBetween:lastAsk to:[NSDate date]] < minIntervalDays) return;
    }

    // 6) 先友好询问，再触发系统评分
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"觉得这个工具好用吗？";
    alert.informativeText = @"如果它帮到了你，花一点时间去 App Store 评价会非常有帮助。";
    [alert addButtonWithTitle:@"去评价"];
    [alert addButtonWithTitle:@"以后再说"];
    [alert addButtonWithTitle:@"不再提示"];

    NSModalResponse resp = [alert runModal];
    if (resp == NSAlertFirstButtonReturn) {
        [ud setObject:[NSDate date] forKey:kLastAskDateKey];
        [ud setObject:ver forKey:kLastAskVersionKey];
        [self requestAppStoreReviewIfPossible];
    } else if (resp == NSAlertSecondButtonReturn) {
        // “以后再说”：建议记录 lastAskDate，然后把 minIntervalDays 改成 14（或单独存一个 laterDate）
        [ud setObject:[NSDate date] forKey:kLastAskDateKey];
    } else {
        [ud setBool:YES forKey:kUserOptOutKey];
    }
}

@end
