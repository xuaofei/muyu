//
//  SetupTableViewCell.m
//  muyu
//
//  Created by xuaofei on 2024/12/7.
//

#import "SetupTableViewCell.h"

@interface SetupTableViewCell ()


@end

@implementation SetupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)swiAction:(id)sender {
    UISwitch *switchCtl = (UISwitch *)sender;
    
    if (self.swiEnableBlock) {
        self.swiEnableBlock(switchCtl.on);
    }
}


@end
