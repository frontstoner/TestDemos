//
//  FaceDetectorViewController.m
//  GPUImageTest
//
//  Created by frontstone on 2018/11/14.
//  Copyright © 2018 frontstone. All rights reserved.
//

#import "FaceDetectorViewController.h"
#import "AlbumViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "UIImage+FixOrientation.h"


static inline double radians (double degrees) {return degrees * M_PI/180;}

@interface FaceDetectorViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic ,strong) CIDetector* detector;

@property (nonatomic, strong) UILabel *leftEyeMaskView;
@property (nonatomic, strong) UILabel *rightEyeMaskView;
@property (nonatomic, strong) UIView *mouthView;
@property (nonatomic, strong) UIView *faceView;
@property (nonatomic, strong) UIView *resultView;
@property (weak, nonatomic) IBOutlet UIImageView *detetorImageView;


@property (nonatomic, strong) UIImagePickerController *pc;

@end

@implementation FaceDetectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCameraCapture];
//    [self pickImageSource];
    
    [self.view addSubview:self.resultView];
    [self.resultView addSubview:self.faceView];
    [self.resultView addSubview:self.rightEyeMaskView];
    [self.resultView addSubview:self.leftEyeMaskView];
    [self.resultView addSubview:self.mouthView];
    
    self.detetorImageView.frame = [UIScreen mainScreen].bounds;
}


- (void)pickImageSource {
    UIImagePickerController *pc = [[UIImagePickerController alloc] init];
    pc.delegate = self;
    pc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.pc = pc;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CGFloat ratio = image.size.width / image.size.height;
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.detetorImageView.frame = CGRectMake(0, 0, screenWidth, screenWidth * ratio);
    self.resultView.frame = self.detetorImageView.frame;
    self.detetorImageView.image = image;
    [self faceTextByImage:ciImage];
}

- (void)initCameraCapture {
    self.session = [AVCaptureSession new];
    [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:[self frontCamera] error:nil];
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    
    AVCaptureVideoDataOutput *videoDataOutput = [AVCaptureVideoDataOutput new];
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                       [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [videoDataOutput setVideoSettings:rgbOutputSettings];
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    if ([self.session canAddOutput:videoDataOutput]){
        [self.session addOutput:videoDataOutput];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];// 犹豫使用的aspectPerserve
    CALayer *rootLayer = [self.view layer];
    [rootLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:[UIScreen mainScreen].bounds];
    [rootLayer addSublayer:self.previewLayer];
    [self.session startRunning];
}

- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:imageBuffer];
    UIImage *image = [UIImage imageWithCIImage:ciImage];
    dispatch_async(dispatch_get_main_queue(), ^{
         [self faceTextByImage:ciImage];
    });
   
}


- (void)faceTextByImage:(CIImage *)image{
    NSArray* features = [self.detector featuresInImage:image];
    if (features.count == 0) {
        self.resultView.hidden = YES;
        return;
    }
    self.resultView.hidden = NO;
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    NSLog(@"image extent frame = %@",NSStringFromCGRect(image.extent));
    CGFloat ratioW = width/image.extent.size.height;
    CGFloat ratioH = height/image.extent.size.width;
    
    for (CIFaceFeature *faceFeature in features){
        NSLog(@"face rect = %@",NSStringFromCGRect(faceFeature.bounds));
        CGRect rect = CGRectMake(faceFeature.bounds.origin.x * ratioW, faceFeature.bounds.origin.y * ratioH, faceFeature.bounds.size.width * ratioW, faceFeature.bounds.size.height * ratioH);
        CGFloat faceWidth = rect.size.width;
        self.faceView.frame = rect;
        CGFloat  ratio = ratioW /width;
        if(faceFeature.hasLeftEyePosition) {
            self.leftEyeMaskView.frame = CGRectMake(0, 0, faceWidth*0.3, faceWidth*0.3);
            [self.leftEyeMaskView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            [self.leftEyeMaskView setCenter:CGPointMake(faceFeature.leftEyePosition.x * ratio, faceFeature.leftEyePosition.y * ratio)];
            self.leftEyeMaskView.layer.cornerRadius = faceWidth*0.15;
        }
        if(faceFeature.hasRightEyePosition) {
            self.rightEyeMaskView.frame = CGRectMake(0, 0, faceWidth*0.3, faceWidth*0.3);
            [self.rightEyeMaskView setCenter:CGPointMake(faceFeature.rightEyePosition.x * ratio, faceFeature.rightEyePosition.y * ratio)];
            self.rightEyeMaskView.layer.cornerRadius = faceWidth*0.15;
        }
        if(faceFeature.hasMouthPosition) {
            self.mouthView.frame = CGRectMake(0 , 0, faceWidth*0.4, faceWidth*0.4);
            self.mouthView.center = CGPointMake(faceFeature.mouthPosition.x * ratio, faceFeature.mouthPosition.y * ratio);
            self.mouthView.layer.cornerRadius = faceWidth*0.2;
        }
    }
    self.resultView.frame = self.detetorImageView.frame;
    [self.resultView setTransform:CGAffineTransformMakeScale(1, -1)];
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    
}

- (IBAction)videoPicker:(id)sender {
    [self presentViewController:self.pc animated:YES completion:^{
    }];
}

- (UILabel *)leftEyeMaskView {
    if (!_leftEyeMaskView) {
        _leftEyeMaskView = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 100, 100))];
        _leftEyeMaskView.layer.cornerRadius = 50;
        _leftEyeMaskView.layer.masksToBounds = YES;
        _leftEyeMaskView.font = [UIFont systemFontOfSize:12];
        _leftEyeMaskView.text = @"左眼";
        _leftEyeMaskView.textAlignment = NSTextAlignmentCenter;
        _leftEyeMaskView.backgroundColor = [UIColor redColor];
    }
    return _leftEyeMaskView;
}

- (UILabel *)rightEyeMaskView {
    if (!_rightEyeMaskView) {
        _rightEyeMaskView = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 100, 100))];
        _rightEyeMaskView.layer.cornerRadius = 50;
        _rightEyeMaskView.font = [UIFont systemFontOfSize:12];
        _rightEyeMaskView.layer.masksToBounds = YES;
        _rightEyeMaskView.text = @"右眼";
        _rightEyeMaskView.textAlignment = NSTextAlignmentCenter;
        _rightEyeMaskView.backgroundColor = [UIColor redColor];
    }
    return _rightEyeMaskView;
}

- (UIView *)mouthView {
    if (!_mouthView) {
        _mouthView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 0, 0))];
        _mouthView.backgroundColor = [UIColor whiteColor];
    }
    return _mouthView;
}

- (UIView *)faceView {
    if (!_faceView) {
        _faceView = [[UIView alloc] init];
        _faceView.layer.borderColor = [UIColor redColor].CGColor;
        _faceView.layer.borderWidth = 1;
    }
    return _faceView;
}

- (UIView *)resultView {
    if (!_resultView) {
        _resultView = [[UIView alloc] initWithFrame:CGRectZero];
        _resultView.backgroundColor = [UIColor colorWithWhite:0 alpha:.2];
    }
    return _resultView;
}

- (CIDetector *)detector {
    if (!_detector) {
        NSDictionary* opts = @{CIDetectorAccuracyHigh:CIDetectorAccuracy,CIDetectorImageOrientation:@(kCGImagePropertyOrientationUp)};
     _detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                        context:nil options:opts];
    }
    return _detector;
}

@end
