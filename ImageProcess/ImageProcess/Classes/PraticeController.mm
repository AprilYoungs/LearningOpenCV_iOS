//
//  PraticeController.m
//  ImageProcess
//
//  Created by Young on 1/9/19.
//  Copyright © 2019 Young. All rights reserved.
//
#import "CVTool.hh"

#import "PraticeController.h"
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>
#import "KMPickerController.h"

#import <iostream>
#import <opencv2/videoio/cap_ios.h>


#define CAFFE

const cv::Scalar meanVal(104.0, 177.0, 123.0);
const double inScaleFactor = 1.0;
const size_t inWidth = 300;
const size_t inHeight = 300;
const float confidenceThreshold = 0.7;

@interface PraticeController ()
<CvVideoCameraDelegate>
{
    cv::CascadeClassifier cascadeClassifier;
    cv::dnn::Net net;
}
@property (strong, nonatomic) CvVideoCamera *videoCamera;

@property (assign, nonatomic) BOOL backCamera;

@property (nonatomic,strong)UIImageView *imageView;
@property (strong, nonatomic) UIButton *btnSave;

@end

@implementation PraticeController

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = YES;
    
    [self setupDetectionModel];
    [self setupUI];
    
    [self.videoCamera start];
    
    
    /** observer the volume button events */
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImage) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
}

- (void)setupDetectionModel
{
    cascadeClassifier = cv::CascadeClassifier([self cppPath:@"haarcascade_frontalface_default.xml"]);
    
    const std::string caffeConfigFile = [self cppPath:@"deploy.prototxt"];
    const std::string caffeWeightFile = [self cppPath:@"res10_300x300_ssd_iter_140000_fp16.caffemodel"];
    
    const std::string tfConfigFile = [self cppPath:@"opencv_face_detector.pbtxt"];
    const std::string tfWeightFile = [self cppPath:@"opencv_face_detector_uint8.pb"];
    
#ifdef CAFFE
    net = cv::dnn::readNetFromCaffe(caffeConfigFile, caffeWeightFile);
#else
    net = cv::dnn::readNetFromTensorflow(tfWeightFile, tfConfigFile);
#endif
    
    
}


- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    self.imageView.frame = self.view.bounds;
    
    UIButton *switchBtn = [[UIButton alloc] init];
    [switchBtn setImage:[UIImage imageNamed:@"switch_camera_black"] forState:UIControlStateNormal];
    [switchBtn addTarget:self action:@selector(switchCameras) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:switchBtn];
    
    self.btnSave = [[UIButton alloc] init];
    [self.btnSave setImage:[UIImage imageNamed:@"shoot_highlight"] forState:UIControlStateHighlighted];
    [self.btnSave setImage:[UIImage imageNamed:@"shoot"] forState:UIControlStateNormal];
    [self.btnSave setImage:[UIImage imageNamed:@"shooted"] forState:UIControlStateSelected];
    [self.btnSave addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSave];
    [self.btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop).offset(-10);
    }];
    
    UIButton *btnFilter = [[UIButton alloc] init];
    [btnFilter setImage:[UIImage imageNamed:@"filter_black"] forState:UIControlStateNormal];

    UIBarButtonItem *fliterItem = [[UIBarButtonItem alloc] initWithCustomView:btnFilter];
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems:@[flexItem, fliterItem]];
    self.navigationController.toolbar.tintColor = [UIColor blackColor];
    
    /** remove system volumeview */
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:{{-20,-20},{5,5}}];
    volumeView.hidden = NO;
    [self.view addSubview:volumeView];
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
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
    
}

//MARK: - CvVideoCameraDelegate
#ifdef __cplusplus
-(void)processImage:(cv::Mat &)image
{
    
#define CASCADE
    /** cascade 算法,效果较差 */
#ifdef CASCADE
    CGFloat scale = 2;  //缩小输入图片
    cv::Mat imageCopy;
    int new_height = image.rows/scale;
    int new_width = image.cols/scale;
    cv::resize(image, imageCopy, cv::Size(new_width, new_height));
    std::vector<cv::Rect> faces;  //存储检查脸位置
    
    cascadeClassifier.detectMultiScale(imageCopy, faces);
    for (size_t i=0; i < faces.size(); i++)
    {
        std::cout << faces[i] << "\n";
        int x = faces[i].x * scale;
        int y = faces[i].y * scale;
        int xx = x+faces[i].width * scale;
        int yy = y+faces[i].height * scale;
        cv::rectangle(image, cv::Point(x, y), cv::Point(xx, yy), cv::Scalar(0, 0, 240), 3);
    }
#endif
    
    /** 深度模型 */
#warning 数据格式不对,传递失败
//    detectFaceDNN(net, image);
    
    UIImage *uiImg = [CVTool imageFromCVMat:image];
    
    
//    if (!self.backCamera)
//    {
//        /** flip the image for front camera */
//        uiImg = [UIImage imageWithCGImage:uiImg.CGImage scale:1 orientation:UIImageOrientationUpMirrored];
//    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.imageView.image = uiImg;
    });
}

#endif


void detectFaceDNN(cv::dnn::Net net, cv::Mat &frameOpenCVDNN)
{
    int frameHeight = frameOpenCVDNN.rows;
    int frameWidth = frameOpenCVDNN.cols;

    
    cv::Mat inputBlob;
#ifdef CAFFE
    inputBlob = cv::dnn::blobFromImage(frameOpenCVDNN, inScaleFactor, cv::Size(inWidth, inHeight), meanVal, false, false);
#else
    inputBlob = cv::dnn::blobFromImage(frameOpenCVDNN, inScaleFactor, cv::Size(inWidth, inHeight), meanVal, true, false);
#endif
    
    
    std::cout << "inputBlob->" << inputBlob.dims << " " << inputBlob.rows << " " << inputBlob.cols << "\n";
    std::cout << "inputBlob-data->" << inputBlob.data << "\n";
    
    
    net.setInput(inputBlob, "data");
    
    try {
        cv::Mat detection = net.forward("detection_out");
        cv::Mat detectionMat(detection.size[2], detection.size[3], CV_32F, detection.ptr<float>());
        
        for (int i = 0; i < detectionMat.rows; i++)
        {
            float confidence = detectionMat.at<float>(i, 2);
            
            if (confidence > confidenceThreshold)
            {
                int x1 = static_cast<int>(detectionMat.at<float>(i, 3))*frameWidth;
                int y1 = static_cast<int>(detectionMat.at<float>(i, 4))*frameHeight;
                int x2 = static_cast<int>(detectionMat.at<float>(i, 5))*frameWidth;
                int y2 = static_cast<int>(detectionMat.at<float>(i, 6))*frameHeight;
                
                cv::rectangle(frameOpenCVDNN, cv::Point(x1, y1), cv::Point(x2, y2), cv::Scalar(0, 255, 0), 2, 4);
            }
        }
        
    } catch (const std::exception & e) {
        
        std::cout << e.what() << "\n";
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    [self.navigationController setToolbarHidden:!self.navigationController.toolbarHidden animated:YES];
}

- (std::string)cppPath:(NSString *)filename
{
    NSString *model_path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    std::string c_path = std::string([model_path UTF8String]);
    
    return c_path;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
}

@end
