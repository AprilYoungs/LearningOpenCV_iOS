//
//  UIViewController+AlertView.h
//  CDSHG
//
//  Created by April Yang on 01/03/2018.
//  Copyright © 2018 KMHealthDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AlertView)


/**
 弹出提示框

 @param title 标题
 @param content 正文
 @param conformStr 确定按钮的文字
 @param conformAction 确定的回调
 @param cancelStr 取消按钮的文字
 @param cancelAction 取消的回调
 @return 返回并弹出AlertController
 */

-(UIAlertController *)showAlertWithTitle:(NSString *)title content:(NSString *)content conformStr:(NSString *)conformStr conformAction:(void(^)(void))conformAction cancelStr:(NSString *)cancelStr cancelAction:(void(^)(void))cancelAction;



/**
 弹出提示框
 
 @param title 标题
 @param content 正文
 @param conformStr 确定按钮的文字
 @param conformAction 确定的回调
 @return 返回并弹出AlertController
 */
-(UIAlertController *)showAlertWithTitle:(NSString *)title content:(NSString *)content conformStr:(NSString *)conformStr conformAction :(void (^)(void))conformAction;
@end
