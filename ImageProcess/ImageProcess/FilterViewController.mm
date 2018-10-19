//
//  FilterViewController.m
//  CoreMachineLearning
//
//  Created by Young on 10/16/18.
//  Copyright © 2018 Young. All rights reserved.
//

#import "FilterViewController.h"
#import <iostream>
#import <opencv2/videoio/cap_ios.h>
#import "CVTool.hh"

#import "KMPickerController.h"

using namespace std;

@interface FilterViewController ()
<CvVideoCameraDelegate>
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *btnSwitch;
@property (strong, nonatomic) KMPickerController *pickerView;
@property (strong, nonatomic) CvVideoCamera *videoCamera;
@property (assign, nonatomic) NSUInteger currentIndex;
@property (strong, nonatomic)  NSArray<NSString *> *filters;
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
    [self.btnSwitch setTitle:@"switch" forState:UIControlStateNormal];
    [self.btnSwitch addTarget:self action:@selector(switchCameras) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSwitch];
    [self.btnSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.mas_topLayoutGuideTop).mas_offset(30);
        make.size.mas_equalTo(CGSizeMake(80, 30));
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

//MARK: - CvVideoCameraDelegate
#ifdef __cplusplus
-(void)processImage:(cv::Mat &)image
{
    
    switch (self.currentIndex) {
        case 0: /** canny */
        {
            cv::Mat gray;
            cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
            cv::Mat canny;
            cv::Canny(gray, canny, 50, 110);
            //    canny = 255 - canny;
            cv::cvtColor(canny, image, cv::COLOR_GRAY2RGBA);
        }
            break;
        case 1: /** canny */
        {
            cv::Mat gray;
            cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
            cv::Mat canny;
            cv::Canny(gray, canny, 50, 110);
            /** reverse color,make it a white background */
            canny = 255 - canny;
            cv::cvtColor(canny, image, cv::COLOR_GRAY2RGBA);
        }
            break;
        case 2: /** Reverse */
        {
            cv::Mat image_copy;
            cv::cvtColor(image, image_copy, cv::COLOR_BGR2GRAY);
            /** reverse color */
            cv::bitwise_not(image_copy, image_copy);
            cv::Mat bgr;
            cv::cvtColor(image_copy, bgr, cv::COLOR_GRAY2BGR);
            /** Only accept three or four channel */
            cv::cvtColor(bgr, image, cv::COLOR_BGR2BGRA);
        }
            break;
        case 3: /** GaussianBlur */
        {
            cv::Size ksize(25,25);
            cv::GaussianBlur(image, image, ksize, 0);
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
            cv::Mat kernel = (cv::Mat_<int>(3,3) <<
                              -2,-2,-2,
                              0,0,0,
                              2,2,2);
            kernel = kernel.t()+kernel;
            cv::filter2D(image, image, -1, kernel);
            cv::cvtColor(image, image, cv::COLOR_BGR2GRAY);
            cv::cvtColor(image, image, cv::COLOR_GRAY2BGR);
        }
            break;
        case 7: /** k-means */
        {
            /** convert 4 channel data to 3 channel */
            cv::cvtColor(image, image, cv::COLOR_BGRA2BGR);
            cv::Mat lineImage(image.rows*image.cols, 3, CV_32F);
            for (int y=0; y<image.rows; y++)
                for(int x=0; x<image.cols; x++)
                    for(int z=0; z<3; z++)
                    {
                        lineImage.at<float>(y + x*image.rows, z) = image.at<cv::Vec3b>(y,x)[z];
                    }
            
            cv::TermCriteria criteria(cv::TermCriteria::MAX_ITER+cv::TermCriteria::EPS, 2, 0.5);
            cv::Mat bestLabels;
            cv::Mat centers;
            
            cv::kmeans(lineImage, 6, bestLabels, criteria, 10, cv::KMEANS_PP_CENTERS, centers);
            cv::Mat new_image(image.size(), image.type());
            for(int y=0; y<image.rows; y++)
                for(int x=0; x<image.cols; x++)
                {
                    int cluster_idx = bestLabels.at<int>(y + x*image.rows,0);
                    new_image.at<cv::Vec3b>(y,x)[0] = centers.at<float>(cluster_idx, 0);
                    new_image.at<cv::Vec3b>(y,x)[1] = centers.at<float>(cluster_idx, 1);
                    new_image.at<cv::Vec3b>(y,x)[2] = centers.at<float>(cluster_idx, 2);
                }
            
            cv::cvtColor(new_image, image, cv::COLOR_BGR2RGB);
        }
            break;
        default:
            break;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = [CVTool imageFromCVMat:image];
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
