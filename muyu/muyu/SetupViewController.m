//
//  SetupViewController.m
//  muyu
//
//  Created by xuaofei on 2024/12/7.
//

#import "SetupViewController.h"
#import "SetupTableViewCell.h"
#import "SetupManager.h"
#import "Define.h"

@interface SetupViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tabSetup;

@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINib *nib = [UINib nibWithNibName:@"SetupTableViewCell" bundle:nil];
    [self.tabSetup registerNib:nib forCellReuseIdentifier:@"SetupTableViewCell"];
    
    self.tabSetup.delegate = self;
    self.tabSetup.dataSource = self;
    [self.tabSetup reloadData];
}

- (IBAction)btnBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
//    UISwitch *customSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 100, 30, 30)];
//
//    // 设置开关为 ON 时的图片
//    customSwitch.onImage = [UIImage imageNamed:@"1_setup"];
//    if (!customSwitch.onImage) {
//        NSLog(@"on_icon image not found!");
//    }
//
//    // 设置开关为 OFF 时的图片
//    customSwitch.offImage = [UIImage imageNamed:@"2_setup"];
//    if (!customSwitch.offImage) {
//        NSLog(@"on_icon image not found!");
//    }
//
//    // 添加到视图
//    [self.view addSubview:customSwitch];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    
    SetupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SetupTableViewCell" forIndexPath:indexPath];
    
    if (0 == indexPath.row) {
        cell.labTitle.text = @"声音";
        cell.swiEnable.on = [[SetupManager sharedInstance] getSoundEnable];
        cell.swiEnableBlock = ^(BOOL enable) {
            [[SetupManager sharedInstance] setSoundEnable:enable];
            [[NSNotificationCenter defaultCenter] postNotificationName:SETUP_CHANGED object:SETUP_SOUND_ENABLE];
        };
    } else if (1 == indexPath.row) {
        cell.labTitle.text = @"震动";
        cell.swiEnable.on = [[SetupManager sharedInstance] getVibrateEnable];
        cell.swiEnableBlock = ^(BOOL enable) {
            [[SetupManager sharedInstance] setVibrateEnable:enable];
            [[NSNotificationCenter defaultCenter] postNotificationName:SETUP_CHANGED object:SETUP_VIBRATE_ENABLE];
        };
    } else if (2 == indexPath.row) {
        cell.labTitle.text = @"显示计数";
        cell.swiEnable.on = [[SetupManager sharedInstance] getShowKnockTotalEnable];
        cell.swiEnableBlock = ^(BOOL enable) {
            [[SetupManager sharedInstance] setShowKnockTotalEnable:enable];
            [[NSNotificationCenter defaultCenter] postNotificationName:SETUP_CHANGED object:SETUP_SHOT_KNOCK_TOTAL_ENABLE];
        };
    } else if (3 == indexPath.row) {
        cell.labTitle.text = @"显示功德";
        cell.swiEnable.on = [[SetupManager sharedInstance] getBubbleEnable];
        cell.swiEnableBlock = ^(BOOL enable) {
            [[SetupManager sharedInstance] setBubbleEnable:enable];
            [[NSNotificationCenter defaultCenter] postNotificationName:SETUP_CHANGED object:SETUP_BUBBLE_ENABLE];
        };
    }
    
    return cell;
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
@end
