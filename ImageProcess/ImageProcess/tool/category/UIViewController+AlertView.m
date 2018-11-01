//
//  UIViewController+AlertView.m
//  CDSHG
//
//  Created by April Yang on 01/03/2018.
//  Copyright © 2018 KMHealthDeveloper. All rights reserved.
//

#import "UIViewController+AlertView.h"

@implementation UIViewController (AlertView)
-(UIAlertController *)showAlertWithTitle:(NSString *)title content:(NSString *)content conformStr:(NSString *)conformStr conformAction:(void (^)(void))conformAction cancelStr:(NSString *)cancelStr cancelAction:(void (^)(void))cancelAction
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    if (conformStr)
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:conformStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (conformAction != nil) conformAction();
        }];
        [alert addAction:action];
    }
    if (cancelStr)
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancelAction != nil) cancelAction();
        }];
        [alert addAction:action];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
    
    return alert;
}

- (UIAlertController *)showAlertWithTitle:(NSString *)title content:(NSString *)content conformStr:(NSString *)conformStr conformAction:(void (^)(void))conformAction
{
    return [self showAlertWithTitle:title content:content conformStr:conformStr conformAction:conformAction cancelStr:nil cancelAction:nil];
}
@end
