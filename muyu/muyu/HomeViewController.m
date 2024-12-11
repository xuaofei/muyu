//
//  HomeViewController.m
//  muyu
//
//  Created by xuaofei on 2024/12/5.
//

#import "Define.h"
#import "HomeViewController.h"
#import "KeyChainHelper.h"
#import "SetupManager.h"
#import "IAPManager.h"


#import <AVFoundation/AVFoundation.h>

@interface HomeViewController ()<AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnFullArea;
@property (weak, nonatomic) IBOutlet UIImageView *imgMuyu;
@property (weak, nonatomic) IBOutlet UILabel *labKnockTitle;
@property (weak, nonatomic) IBOutlet UILabel *labKnockCount;


// 木鱼是否正在敲击，只有敲击结束后才能再次被敲击
@property (assign, nonatomic) BOOL muyuKnocking;
@property (assign, nonatomic) NSUInteger muyuKnockTotal;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // 获取音频文件路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"muyu0_0" ofType:@"wav"];
    if (filePath) {
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        // 初始化 AVAudioPlayer
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        self.audioPlayer.delegate = self; // 可选：设置代理
        
        if (error) {
            NSLog(@"初始化播放器失败: %@", error.localizedDescription);
        } else {
            [self.audioPlayer prepareToPlay]; // 准备播放
        }
    } else {
        
    }
    
    self.muyuKnockTotal = [[KeyChainHelper readFromKeychainWithKey:MUYU_KNOCK_TOTAL] integerValue];
    self.labKnockCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.muyuKnockTotal];
    
    [self applySetupChanged];
    
    
    [[IAPManager sharedManager] fetchProductsWithIdentifiers:@[@"com.example.app.product1", @"com.example.app.product2"]];
    
    // 监听失去焦点（即应用不再活跃）
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupChange:)
                                                 name:SETUP_CHANGED
                                               object:nil];
    
    NSLog(@"NSUIntegerMax:%lu", NSUIntegerMax);
}

- (IBAction)btnSetupAction:(id)sender {
    NSLog(@"btnSetupAction");
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SetupViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)btnFullAreaAction:(id)sender {
    NSLog(@"btnFullAreaAction");
    
    if ([[SetupManager sharedInstance] getSoundEnable]) {
        [self playAudio];
    }
    
    if ([[SetupManager sharedInstance] getVibrateEnable]) {
        [self generateVibrate];
    }
    
    if ([[SetupManager sharedInstance] getBubbleEnable]) {
        [self showBubble];
    }
    
    self.muyuKnockTotal++;
    self.labKnockCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.muyuKnockTotal];
    
    if (self.muyuKnocking) {
        // 如果动画正在进行，立即停止并重置
        [self.imgMuyu.layer removeAllAnimations];
        self.imgMuyu.transform = CGAffineTransformIdentity; // 恢复到初始状态
        self.muyuKnocking = NO; // 重置标志位
    }
    
    // 开始新的动画
    self.muyuKnocking = YES;
    [UIView animateWithDuration:MUYU_ANIMATE_DURATION
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        self.imgMuyu.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        
        if (finished) {
            [UIView animateWithDuration:MUYU_ANIMATE_DURATION
                                  delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                self.imgMuyu.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.muyuKnocking = NO; // 动画完成后重置标志位
                }
            }];
        }
    }];
}

- (void)purchaseButtonTapped:(UIButton *)sender {
//    SKProduct *product = ... // 从 `availableProducts` 中选择商品
//    [[IAPManager sharedManager] purchaseProduct:product];
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    if (!receiptData) {
        NSLog(@"未找到收据");
        // 提示用户恢复购买或重新购买
        return;
    }
    
    NSString *receiptString = [receiptData base64EncodedStringWithOptions:0];
    NSDictionary *parameters = @{@"receipt-data": receiptString};
    // Apple 验证服务器 URL
    // sandbox_url = "https://sandbox.itunes.apple.com/verifyReceipt"
    // production_url = "https://buy.itunes.apple.com/verifyReceipt"
    NSURL *url = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"]; // 或生产环境URL
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"请求错误: %@", error.localizedDescription);
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"验证结果: %@", json);
    }];
    [task resume];

}


// 生成气泡
- (UIView*)generateBubble {
    float imgMuyuMinY = CGRectGetMinY(self.imgMuyu.frame);
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    float screenWidth = CGRectGetWidth(screenRect);
    UILabel *labHappy = [[UILabel alloc] initWithFrame:CGRectMake(0, imgMuyuMinY, screenWidth, 44)];
    labHappy.textAlignment = NSTextAlignmentCenter;
    labHappy.text = @"功德+1";
    labHappy.font = [UIFont systemFontOfSize:20.0f];
    labHappy.textColor = [UIColor whiteColor];
    return labHappy;
}

- (void)animateBubble:(UIView*)view {
    [UIView animateWithDuration:1.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        // 放大到 1.3 倍
        view.transform = CGAffineTransformMakeScale(1.5, 1.5);
        view.alpha = 0.1f;
        
        // 向上移动
        CGRect frame = view.frame;
        frame.origin.y = -CGRectGetHeight(frame);
        view.frame = frame;
    } completion:^(BOOL finished) {
        // 动画完成后，可添加额外逻辑
        NSLog(@"动画完成");
        
        [view removeFromSuperview];
    }];
}

// 显示气泡
- (void)showBubble {
    UIView *bubble = [self generateBubble];
    [self animateBubble:bubble];
    
    [self.view addSubview:bubble];
}

- (void)generateVibrate {
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [generator prepare];
    [generator impactOccurred];
}

- (void)playAudio {
    if (!self.audioPlayer.isPlaying) {
        [self.audioPlayer play];
        NSLog(@"开始播放");
    } else {
        NSLog(@"音频正在播放中");
    }
}

- (void)stopAudio {
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
        NSLog(@"停止播放");
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        NSLog(@"音频播放完成");
    }
}


// 应用失去焦点时触发
- (void)applicationWillResignActive:(NSNotification *)notification {
    NSString *muyuKnockCountStr = [NSString stringWithFormat:@"%lu", (unsigned long)self.muyuKnockTotal];
    
    [KeyChainHelper saveToKeychainWithKey:MUYU_KNOCK_TOTAL value:muyuKnockCountStr];
    
    NSLog(@"Application will resign active (失去焦点)");
}

- (void)setupChange:(NSNotification *)notification {
    NSString *type = notification.object;
    
    [self applySetupChanged];
}

- (void)applySetupChanged {
    self.labKnockTitle.hidden = ![[SetupManager sharedInstance] getShowKnockTotalEnable];
    self.labKnockCount.hidden = ![[SetupManager sharedInstance] getShowKnockTotalEnable];
}

@end
