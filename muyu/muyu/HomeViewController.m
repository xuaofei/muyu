//
//  HomeViewController.m
//  muyu
//
//  Created by xuaofei on 2024/12/5.
//

#import "Define.h"
#import "HomeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface HomeViewController ()<AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnFullArea;
@property (weak, nonatomic) IBOutlet UIImageView *imgMuyu;
@property (weak, nonatomic) IBOutlet UILabel *labKnockCount;


// 木鱼是否正在敲击，只有敲击结束后才能再次被敲击
@property (assign, nonatomic) BOOL muyuKnocking;
@property (assign, nonatomic) NSUInteger muyuKnockCount;
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
    
    NSLog(@"NSUIntegerMax:%lu", NSUIntegerMax);
}

- (IBAction)btnFullAreaAction:(id)sender {
    NSLog(@"btnFullAreaAction");
    
    [self playAudio];
    self.muyuKnockCount++;
    self.labKnockCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.muyuKnockCount];
    
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


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
