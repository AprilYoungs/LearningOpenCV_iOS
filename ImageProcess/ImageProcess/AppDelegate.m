//
//  AppDelegate.m
//  ImageProcess
//
//  Created by Young on 10/16/18.
//  Copyright © 2018 Young. All rights reserved.
//

#import "AppDelegate.h"
#import "FilterViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    FilterViewController *filter = [[FilterViewController alloc] init];
    self.window.rootViewController = filter;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
