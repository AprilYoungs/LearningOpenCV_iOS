//
//  FilterViewController.m
//  CoreMachineLearning
//
//  Created by Young on 10/16/18.
//  Copyright © 2018 Young. All rights reserved.
//  With opencv encapsulate camera,can't save photo as expected

#import "FilterViewController.h"
#import <iostream>
#import <opencv2/videoio/cap_ios.h>
#import "CVTool.hh"

#import "KMPickerController.h"
#import <Photos/Photos.h>

using namespace std;

@interface FilterViewController ()
<CvVideoCameraDelegate>
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *currentImage;
@property (strong, nonatomic) UIButton *btnSwitch;
@property (strong, nonatomic) UIButton *btnSave;
@property (strong, nonatomic) KMPickerController *pickerView;
@property (strong, nonatomic) CvVideoCamera *videoCamera;
@property (assign, nonatomic) NSUInteger currentIndex;
@property (strong, nonatomic) NSArray<NSString *> *filters;
@end

@implementation FilterViewController

-(NSArray<NSString *> *)filters
{
    if (_filters)
        return _filters;
    _filters = @[@"Canny", @"Canny white", @"Reverse", @"GaussianBlur", @"Crop rect", @"Horror Crop", @"Sobel", @"K-means", @"Original"];
    return _filters;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self.videoCamera start];
}

- (void)setupUI
{
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"Screen"];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    self.imageView.frame = CGRectMake(0, 0, width, width/9*16);
    self.imageView.center = CGPointMake(width/2, height/2);
    
    self.btnSwitch = [[UIButton alloc] init];
    [self.btnSwitch setImage:[UIImage imageNamed:@"switch_camera"] forState:UIControlStateNormal];
    [self.btnSwitch addTarget:self action:@selector(switchCameras) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSwitch];
    [self.btnSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.mas_topLayoutGuideTop).mas_offset(30);
    }];
    
    self.btnSave = [[UIButton alloc] init];
    [self.btnSave setImage:[UIImage imageNamed:@"shoot_highlight"] forState:UIControlStateHighlighted];
    [self.btnSave setImage:[UIImage imageNamed:@"shoot"] forState:UIControlStateNormal];
    [self.btnSave addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSave];
    [self.btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-64);
    }];
    
    self.videoCamera = [[CvVideoCamera alloc]initWithParentView:self.imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    self.videoCamera.delegate = self;
    
}

- (void)switchCameras
{
    /** switch to another side */
    self.videoCamera.defaultAVCaptureDevicePosition = self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront: AVCaptureDevicePositionBack;
    [self.videoCamera stop];
    [self.videoCamera start];
}

- (void)saveImage
{

//    if ([self.videoCamera running])
//    {
//        [self.videoCamera stop];
//    }
//    else
//    {
//        [self.videoCamera start];
//    }
    
//    self.imageView.image = self.currentImage;
    
    
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

        __unused PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:self.currentImage];

    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success = %d, error = %@", success, error);
//        [self.videoCamera start];
    }];
}


//MARK: - CvVideoCameraDelegate
#ifdef __cplusplus
-(void)processImage:(cv::Mat &)image
{

    switch (self.currentIndex) {
        case 0: /** canny */
        {
            image = [CVTool processCVImage:image cvEffect:kCVCanny];
        }
            break;
        case 1: /** canny white */
        {
            image = [CVTool processCVImage:image cvEffect:kCVCannyWhite];
        }
            break;
        case 2: /** Reverse */
        {
            image = [CVTool processCVImage:image cvEffect:kCVReverse];
        }
            break;
        case 3: /** GaussianBlur */
        {
            image = [CVTool processCVImage:image cvEffect:kCVGaussianBlur];
        }
            break;
        case 4: /** Crop rect */
        {
            CGFloat scale = 9.0/16;
            CGFloat x = image.cols * 0.2;
            CGFloat width = image.cols * 0.5;
            cv::Mat image_copy = cv::Mat(image, cv::Rect(x, x/scale, width, width/scale));
            image = image_copy.clone();
            cv::cvtColor(image, image, cv::COLOR_BGR2RGB);
        }
            break;
        case 5: /** Horror Crop */
        {
            CGFloat scale = 9.0/16;
            CGFloat x = image.cols * 0.2;
            CGFloat width = image.cols * 0.5;
            cv::Mat image_copy = cv::Mat(image, cv::Rect(x, x/scale, width, width/scale+100));
            image = image_copy.clone();
        }
            break;
        case 6: /** sobel */
        {
            image = [CVTool processCVImage:image cvEffect:kCVSobel];
        }
            break;
        case 7: /** k-means */
        {
            image = [CVTool processCVImage:image cvEffect:kCVK_Means];
        }
            break;
        default:
            break;
    }
    
    self.currentImage = [CVTool imageFromCVMat:image];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.currentImage != nil)
            self.imageView.image = self.currentImage;
    });
}


#endif

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    self.pickerView = [KMPickerController pickerViewWithSourceView:self.view andDataArr:self.filters callback:^(NSUInteger index) {
        self.currentIndex = index;
    }];
    self.pickerView.defaultIndex = self.currentIndex;
    
    [self presentViewController:self.pickerView animated:YES completion:nil];
}

@end
