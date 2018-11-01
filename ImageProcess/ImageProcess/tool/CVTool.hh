//
//  CVTool.h
//  ImageProcess
//
//  Created by Young on 10/16/18.
//  Copyright © 2018 Young. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kCVCanny,
    kCVCannyWhite,
    kCVReverse,
    kCVGaussianBlur,
    kCVSobel,
    kCVK_Means
} CVEffect;

NS_ASSUME_NONNULL_BEGIN

@interface CVTool : NSObject

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (UIImage *)imageFromCVMat:(cv::Mat)cvMat;

+ (cv::Mat)processCVImage:(cv::Mat &)image cvEffect:(CVEffect)effect;
+ (UIImage *)processImage:(UIImage *)image cvEffect:(CVEffect)effect;
@end

NS_ASSUME_NONNULL_END
