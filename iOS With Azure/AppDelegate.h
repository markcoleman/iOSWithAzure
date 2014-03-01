//
//  AppDelegate.h
//  iOS With Azure
//
//  Created by Coleman, Mark on 3/1/14.
//  Copyright (c) 2014 Coleman, Mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WindowsAzureMobileServices.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MSClient *client;

@end
