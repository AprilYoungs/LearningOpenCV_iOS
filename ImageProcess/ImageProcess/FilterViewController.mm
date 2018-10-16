//
//  FilterViewController.m
//  CoreMachineLearning
//
//  Created by Young on 10/16/18.
//  Copyright © 2018 Young. All rights reserved.
//

#import "FilterViewController.h"
#import <opencv2/videoio/cap_ios.h>
#import "CVTool.hh"

@interface FilterViewController ()
<CvVideoCameraDelegate>
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) CvVideoCamera *videoCamera;
@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    
    [self setupUI];
    
    [self.videoCamera start];
}

- (void)setupUI
{
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"Screen"];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    self.imageView.frame = self.view.bounds;
    
    
    self.videoCamera = [[CvVideoCamera alloc]initWithParentView:self.imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    self.videoCamera.delegate = self;
    
}

//MARK: - CvVideoCameraDelegate
#ifdef __cplusplus
-(void)processImage:(cv::Mat &)image
{
    
//    cv::Mat image_copy;
//    cv::cvtColor(image, image_copy, cv::COLOR_BGR2GRAY);
//
//    /** reverse color */
//    cv::bitwise_not(image_copy, image_copy);
//    cv::Mat bgr;
//    cv::cvtColor(image_copy, bgr, cv::COLOR_GRAY2BGR);
//    /** Only accept three or four channel */
//    cv::cvtColor(bgr, image, cv::COLOR_BGR2BGRA);
    
    
    
    /** canny process */
    cv::Mat gray;
    cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
    cv::Mat canny;
    cv::Canny(gray, canny, 50, 110);
    canny = 255 - canny;
    
    cv::cvtColor(canny, image, cv::COLOR_GRAY2BGRA);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = [CVTool imageFromCVMat:image];
    });
}

#endif
@end
