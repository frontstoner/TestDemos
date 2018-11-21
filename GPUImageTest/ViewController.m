//
//  ViewController.m
//  GPUImageTest
//
//  Created by frontstone on 2018/11/13.
//  Copyright © 2018 frontstone. All rights reserved.
//

#import "ViewController.h"

#import "CameraViewController.h"
#import "AlbumViewController.h"
#import "FaceDetectorViewController.h"
#import "VideoQuickSlowViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
}

- (IBAction)presentAction:(id)sender {
    CameraViewController *vc = [[CameraViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)photoAction:(id)sender {
    AlbumViewController *vc = [[AlbumViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)detectorAction:(id)sender {
    FaceDetectorViewController *vc = [[FaceDetectorViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)quickSlowAction:(id)sender {
    VideoQuickSlowViewController *vc = [[VideoQuickSlowViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
