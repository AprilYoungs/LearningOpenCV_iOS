//
//  MenuViewController.m
//  ImageProcess
//
//  Created by Young on 10/31/18.
//  Copyright © 2018 Young. All rights reserved.
//

#import "MenuViewController.h"
#import "CameraController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
}

- (IBAction)chosePic:(id)sender {
    
}

- (IBAction)shootingPhoto:(id)sender {
    
    [self.navigationController pushViewController:[[CameraController alloc] init] animated:YES];
    
}

@end
