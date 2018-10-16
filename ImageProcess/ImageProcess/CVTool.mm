//
//  CVTool.m
//  ImageProcess
//
//  Created by Young on 10/16/18.
//  Copyright © 2018 Young. All rights reserved.
//

#import "CVTool.hh"

@implementation CVTool

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
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

+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
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


+ (UIImage *)imageFromCVMat:(cv::Mat)cvMat
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
