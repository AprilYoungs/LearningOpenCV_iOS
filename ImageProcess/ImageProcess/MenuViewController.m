//
//  MenuViewController.m
//  ImageProcess
//
//  Created by Young on 10/31/18.
//  Copyright © 2018 Young. All rights reserved.
//

#import "MenuViewController.h"
#import "CameraController.h"
#import "ImageEditController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (IBAction)chosePic:(id)sender {
    ImageEditController *editController = [[ImageEditController alloc] init];
    [self.navigationController pushViewController:editController animated:YES];
}

- (IBAction)shootingPhoto:(id)sender {
    
    [self.navigationController pushViewController:[[CameraController alloc] init] animated:YES];
}


@end
