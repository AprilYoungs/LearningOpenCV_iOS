//
//  OCViewController.h
//  VideoCapture
//
//  Created by April Young on 2/10/2017.
//  Copyright © 2017 April. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraController : UIViewController
+ (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
@end
