//
//  FilterViewController.m
//  CoreMachineLearning
//
//  Created by Young on 10/16/18.
//  Copyright © 2018 Young. All rights reserved.
//

#import "FilterViewController.h"
#import <opencv2/videoio/cap_ios.h>

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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    cv::Mat mat = [self cvMatFromUIImage:self.imageView.image];
    cv::Mat grayMat;
    cv::cvtColor(mat, grayMat, cv::COLOR_RGBA2GRAY);
    UIImage *grayImage = [self imageFromCVMat:grayMat];
    
    self.imageView.image = grayImage;
    
    NSLog(@"Touch");
    
}

//MARK: - CvVideoCameraDelegate
#ifdef __cplusplus
-(void)processImage:(cv::Mat &)image
{

    cv::Mat image_copy;
    cv::cvtColor(image, image_copy, cv::COLOR_BGR2GRAY);
    
    cv::bitwise_not(image_copy, image_copy);

    cv::Mat bgr;
    cv::cvtColor(image_copy, bgr, cv::COLOR_GRAY2BGR);

    cv::cvtColor(bgr, image, cv::COLOR_BGR2BGRA);
    
    UIImage *grayImage = [self imageFromCVMat:image];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = grayImage;
    });
    
}
#endif

//MARK: - OpenCV code
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4);

    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,  // Pointer to  data
                                                    cols,        // Width of bitmap
                                                    rows,        // Height of bitmap
                                                    8,           // Bits per component
                                                    cvMat.step[0],  // Bytes per row
                                                    colorSpace,     // Colorspace
                                                    kCGImageAlphaNoneSkipLast|
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);

    return cvMat;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1);
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data, // Pointer to data
                                                    cols, // Width of bitmap
                                                    rows, // Height of bitmap
                                                    8,  // Bits per component
                                                    cvMat.step[0], // Bytes per row
                                                    colorSpace, // Colorspace
                                                    kCGImageAlphaNoneSkipLast|
                                                    kCGBitmapByteOrderDefault  // Bitmap info flags
                                                    );
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}


- (UIImage *)imageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1)
    {
        colorSpace = CGColorSpaceCreateDeviceGray();
    }else
    {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols, //width
                                        cvMat.rows, //height
                                        8,   //bits per component
                                        8*cvMat.elemSize(),  //bits per pixel
                                        cvMat.step[0], //bytesPerRow
                                        colorSpace,     //colorspace
                                        kCGImageAlphaNoneSkipLast|
                                        kCGBitmapByteOrderDefault, // bitmap info
                                        provider,   //CGDataProviderRef
                                        NULL,   //decode
                                        false,  //should interpolate
                                        kCGRenderingIntentDefault //intent
                                        );
    
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
