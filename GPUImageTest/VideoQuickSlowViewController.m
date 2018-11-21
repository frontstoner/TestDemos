//
//  VideoQuickSlowViewController.m
//  GPUImageTest
//
//  Created by frontstone on 2018/11/21.
//  Copyright © 2018 frontstone. All rights reserved.
//

#import "VideoQuickSlowViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoQuickSlowViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation VideoQuickSlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)playerItemDidPlayToEnd:(NSNotification *)notification{
    if (!self.player) {
        return;
    }
    [self.player seekToTime:(CMTimeMake(1, 30))];
    [self.player play];
}

- (IBAction)pickVideoAction:(id)sender {
    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;
    [vc setMediaTypes:@[(NSString *)kUTTypeMovie]];
    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
//        NSURL *url = ;
//        AVPlayerItem *asset = [AVPlayerItem playerItemWithURL:url];
//        self.player = [[AVPlayer alloc] initWithPlayerItem:asset];
//        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        AVAsset *asset = [AVAsset assetWithURL:info[UIImagePickerControllerMediaURL]];
        AVMutableComposition *composition = [AVMutableComposition composition];
        NSError *error = nil;
        [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                             ofAsset:asset
                              atTime:kCMTimeZero error:&error];
        double videoScaleFactor = 0.1;
        CMTime videoDuration = asset.duration;
        [composition scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration) toDuration:CMTimeMake(videoDuration.value*videoScaleFactor, videoDuration.timescale)];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:composition];
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        self.playerLayer = [AVPlayerLayer layer];
        [self.playerLayer setPlayer:self.player];
        self.playerLayer.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
        [self.view.layer addSublayer:self.playerLayer];
//        [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
//
//        }];
        [self.player play];
    }];
    
}

//- (AVPlayerLayer *)playerLayer {
//    if (!_playerLayer) {
//        _playerLayer = [[AVPlayerLayer alloc] init];
//    }
//    return _playerLayer;
//}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
