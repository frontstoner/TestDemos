//
//  AlbumViewController.m
//  GPUImageTest
//
//  Created by frontstone on 2018/11/13.
//  Copyright © 2018 frontstone. All rights reserved.
//

#import "AlbumViewController.h"
#import <GPUImage.h>

@interface AlbumViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) GPUImageView *visionImageView;

@end

@implementation AlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.visionImageView = [[GPUImageView alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)))];
    [self.view addSubview:self.visionImageView];

}
- (IBAction)albumAction:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {

    [picker dismissViewControllerAnimated:YES completion:^{
        
        UIImage *originImage = info[@"UIImagePickerControllerOriginalImage"];
        GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:originImage];
        GPUImageColorInvertFilter *filter = [[GPUImageColorInvertFilter alloc] init];
        [filter forceProcessingAtSize:self.visionImageView.sizeInPixels];
        [picture addTarget:filter];
        [filter addTarget:self.visionImageView];
        [picture processImage];
    }];
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
