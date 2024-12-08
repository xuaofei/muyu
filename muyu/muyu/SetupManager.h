//
//  SetupManager.h
//  muyu
//
//  Created by xuaofei on 2024/12/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SetupManager : NSObject
+ (instancetype)sharedInstance;
//- (void)setKey:(NSString*)key value:(NSString*)value;
//- (NSString*)getValueWithKey:(NSString*)key;

- (void)setSoundEnable:(BOOL)enable;
- (BOOL)getSoundEnable;

- (void)setVibrateEnable:(BOOL)enable;
- (BOOL)getVibrateEnable;

- (void)setBubbleEnable:(BOOL)enable;
- (BOOL)getBubbleEnable;

- (void)setShowKnockTotalEnable:(BOOL)enable;
- (BOOL)getShowKnockTotalEnable;
@end

NS_ASSUME_NONNULL_END
