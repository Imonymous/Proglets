//
//  AppDelegate.m
//  Proglets
//
//  Created by Iman Mukherjee on 3/3/14.
//  Copyright (c) 2014 GTCMT. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "LoginViewController.h"
#import "TheAmazingAudioEngine.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

@end
