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
#import "KMPickerController.h"

@interface CameraController ()
<AVCaptureVideoDataOutputSampleBufferDelegate
>
@property (nonatomic,strong)AVCaptureSession *session;
@property (nonatomic,strong)AVCaptureDevice *device;
@property (assign, nonatomic) BOOL backCamera;
@property (assign, nonatomic) NSUInteger currentIndex;

@property (nonatomic,strong)UIImageView *imageView;
@property (strong, nonatomic) UIButton *btnSave;
@property (strong, nonatomic) UIButton *btnSwitch;
@property (strong, nonatomic) KMPickerController *pickerView;
@property (strong, nonatomic) NSArray<NSString *> *filters;

@end

@implementation CameraController

-(NSArray<NSString *> *)filters
{
    if (_filters)
        return _filters;
    _filters = @[@"Canny", @"Canny white", @"Reverse", @"GaussianBlur", @"Sobel", @"K-means", @"Original"];
    return _filters;
}

- (void)viewDidLoad
{
    [self setupUI];
    [self setupCaptureSession];
}

- (void)setupUI
{
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    self.imageView.frame = self.view.bounds;
    
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
    
}

- (void)switchCameras
{
    [self.session stopRunning];
    [self setupCaptureSession];
}

- (void)saveImage
{
    UIImage *image = self.imageView.image;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        __unused PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success = %d, error = %@", success, error);
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
    self.backCamera = !self.backCamera;
    AVCaptureDevicePosition position = self.backCamera ?AVCaptureDevicePositionBack: AVCaptureDevicePositionFront;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:position];
    
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
    
    
    switch (self.currentIndex) {
        case 0:
            image = [CVTool processImage:image cvEffect:kCVCanny];
            break;
        case 1:
            image = [CVTool processImage:image cvEffect:kCVCannyWhite];
            break;
        case 2:
            image = [CVTool processImage:image cvEffect:kCVReverse];
            break;
        case 3:
            image = [CVTool processImage:image cvEffect:kCVGaussianBlur];
            break;
        case 4:
            image = [CVTool processImage:image cvEffect:kCVSobel];
            break;
        case 5:
            image = [CVTool processImage:image cvEffect:kCVK_Means];
            break;
        default:
            break;
    }
    
    if (!self.backCamera)
    {
        /** flip the image for front camera */
        image = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationUpMirrored];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.pickerView = [KMPickerController pickerViewWithSourceView:self.view andDataArr:self.filters callback:^(NSUInteger index) {
        self.currentIndex = index;
    }];
    self.pickerView.defaultIndex = self.currentIndex;
    
    [self presentViewController:self.pickerView animated:YES completion:nil];
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
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

@end
