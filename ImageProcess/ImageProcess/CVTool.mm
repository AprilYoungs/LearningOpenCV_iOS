//
//  CVTool.m
//  ImageProcess
//
//  Created by Young on 10/16/18.
//  Copyright © 2018 Young. All rights reserved.
//

#import "CVTool.hh"

using namespace cv;

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
                                        /** why? */
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

+ (cv::Mat)processCVImage:(cv::Mat &)image cvEffect:(CVEffect)effect
{
    switch (effect) {
        case kCVCanny:
        {
            cv::Mat gray;
            cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
            cv::Mat canny;
            cv::Canny(gray, canny, 50, 110);
            cv::cvtColor(canny, image, cv::COLOR_GRAY2RGBA);
        }
            break;
        case kCVCannyWhite:
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
        case kCVReverse:
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
        case kCVGaussianBlur:
        {
            cv::Size ksize(25,25);
            cv::GaussianBlur(image, image, ksize, 0);
        }
            break;
        case kCVSobel:
        {
            cv::Mat kernel = (cv::Mat_<int>(3,3) <<
                              -2,-2,-2,
                              0,0,0,
                              2,2,2);
            kernel = kernel.t()+kernel;
            
            cv::cvtColor(image, image, cv::COLOR_RGBA2GRAY);
            cv::filter2D(image, image, -1, kernel);
            cv::cvtColor(image, image, cv::COLOR_GRAY2RGBA);
        }
            break;
        case kCVK_Means:
        {
            /** convert 4 channel data to 3 channel */
            cv::cvtColor(image, image, cv::COLOR_RGBA2RGB);
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
            
            cv::cvtColor(new_image, image, cv::COLOR_RGB2RGBA);
        }
            break;
        default:
            break;
    }
    return image;
}

+ (UIImage *)processImage:(UIImage *)image cvEffect:(CVEffect)effect
{
    Mat cvImage = [self cvMatFromUIImage:image];
    Mat processImage = [self processCVImage:cvImage cvEffect:effect];
    
    return [self imageFromCVMat:processImage];
}

@end
