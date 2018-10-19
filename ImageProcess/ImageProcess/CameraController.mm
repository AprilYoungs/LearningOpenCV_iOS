//
//  OCViewController.m
//  VideoCapture
//
//  Created by April Young on 2/10/2017.
//  Copyright © 2017 April. All rights reserved.
//

#import "CameraController.h"
#import "CVTool.hh"
#import <Photos/Photos.h>

@interface CameraController ()
<AVCaptureVideoDataOutputSampleBufferDelegate
>
@property (nonatomic,strong)AVCaptureSession *session;
@property (nonatomic,strong)UIImageView *imageView;
@property (strong, nonatomic) UIButton *btnSave;
@property (nonatomic,strong)AVCaptureDevice *device;
@end

@implementation CameraController

- (void)viewDidLoad
{
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:self.imageView atIndex:0];
    [self setupCaptureSession];
    
    
    self.btnSave = [[UIButton alloc] init];
    [self.btnSave setImage:[UIImage imageNamed:@"shoot_highlight"] forState:UIControlStateHighlighted];
    [self.btnSave setImage:[UIImage imageNamed:@"shoot"] forState:UIControlStateNormal];
    [self.btnSave addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSave];
    [self.btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-64);
    }];
    
}

- (void)saveImage
{
    UIImage *image = self.imageView.image;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        __unused PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success = %d, error = %@", success, error);
        //        [self.videoCamera start];
    }];
}

// Create and configure a capture session and start it running
- (void)setupCaptureSession
{
    NSError *error = nil;
    
    // Create the session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    session.sessionPreset = AVCaptureSessionPresetHigh;

    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    
    
    [self setDevice:device];
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (!input) {
        // Handling the error appropriately.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tips" message:@"Can't found any input device" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"conform" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [session addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:output];
    
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    [output connectionWithMediaType:AVMediaTypeVideo].videoOrientation = AVCaptureVideoOrientationPortrait;
    // If you wish to cap the frame rate to a known value, such as 15 fps, set
    // minFrameDuration.
//    output.minFrameDuration = CMTimeMake(1, 15);
    
//    device.activeVideoMinFrameDuration = CMTimeMake(1, 15);
    // Start the session running to start the flow of data
    [session startRunning];
    
    
//    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
//    previewLayer.frame = self.view.frame;
//    [self.view.layer addSublayer:previewLayer];
    
    
    // Assign session to an ivar.
    [self setSession:session];
    
    
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    
    // Create a UIImage from the sample buffer data
    UIImage *image = [CameraController imageFromSampleBuffer:sampleBuffer];
    
    cv::Mat cvImage = [CVTool cvMatFromUIImage:image];
    
    cv::Size ksize(25,25);
    cv::Mat blur;
    cv::GaussianBlur(cvImage, blur, ksize, 0);
    
    /** convert the image to gray,
     1.convert to gray then the mat lose 3 channel
     2.convert to RGBA then iOS can display,however,
     the four channel have the same value,so it's gray now*/
//    cv::cvtColor(blur, blur, cv::COLOR_RGBA2GRAY);
//    cv::cvtColor(blur, blur, cv::COLOR_GRAY2RGBA);
    
    //TODO: construct my mat
    // ?? Gray Images? why not
//    cv::InputArray kernel(cv::Scalar(0,0,0));
//    cv::filter2D(blur, blur, -1,kernel);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.imageView.image = image;
        self.imageView.image = [CVTool imageFromCVMat:blur];
    });
}

// Create a UIImage from sample buffer data
+ (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}


@end
