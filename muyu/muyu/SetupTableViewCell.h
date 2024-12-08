//
//  SetupTableViewCell.h
//  muyu
//
//  Created by xuaofei on 2024/12/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SwiEnableFun)(BOOL);

@interface SetupTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UISwitch *swiEnable;

@property (copy, nonatomic) SwiEnableFun swiEnableBlock;
@end

NS_ASSUME_NONNULL_END
