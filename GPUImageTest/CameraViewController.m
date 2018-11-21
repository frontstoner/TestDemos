//
//  CameraViewController.m
//  GPUImageTest
//
//  Created by frontstone on 2018/11/13.
//  Copyright © 2018 frontstone. All rights reserved.
//

#import "CameraViewController.h"

#import <GPUImage.h>

@interface CameraViewController ()
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) GPUImageVideoCamera *camera;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) GPUImageColorInvertFilter *beautifyFilter;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorFrontFacingCamera = YES;
    
    GPUImageView *outputView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    outputView.backgroundColor = [UIColor clearColor]; 
    [self.view addSubview:outputView];
    
    self.beautifyFilter = [[GPUImageColorInvertFilter alloc] init];
    [self.camera addTarget:self.beautifyFilter];
    [self.beautifyFilter addTarget:outputView];
    [self.view bringSubviewToFront:self.recordButton];
    [self.camera startCameraCapture];
}
- (IBAction)recordAction:(id)sender {
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    
    self.camera.audioEncodingTarget = _movieWriter;
    _movieWriter.encodingLiveVideo = YES;
    [_movieWriter startRecording];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.beautifyFilter removeTarget:self.movieWriter];
        [self.movieWriter finishRecording];
        UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToMovie);
    });
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

