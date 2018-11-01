//
//  KMPickerController.h
//  KMHealth-iPhone
//
//  Created by Young on 8/9/18.
//  Copyright © 2018 KM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectBlock)(NSUInteger index);

@interface KMPickerController : UIViewController
@property (strong, nonatomic) NSArray *dataArr;
/** 启动的时候默认选择的index */
@property (assign, nonatomic) NSInteger defaultIndex;

/** pickerview 项目的颜色 */
@property (strong, nonatomic) UIColor *attColor;

/**
 pop 出来一个 pickerview
 需要 present 出来

 @param sourceView pop 出来的位置
 @param dataArr string 数组
 @param callback 选中index
 @return This pickerview
 */
+ (instancetype)pickerViewWithSourceView:(UIView *)sourceView andDataArr:(NSArray *)dataArr callback:(SelectBlock) callback;
@end
