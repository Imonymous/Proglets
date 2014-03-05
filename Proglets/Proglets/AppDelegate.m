//
//  AppDelegate.m
//  Proglets
//
//  Created by Iman Mukherjee on 3/3/14.
//  Copyright (c) 2014 GTCMT. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "TheAmazingAudioEngine.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize audioController = _audioController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // Create an instance of the audio controller, set it up and start it running
    self.audioController = [[[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:YES] autorelease];
    _audioController.preferredBufferDuration = 0.005;
    [_audioController start:NULL];
    
    // Create and display view controller
    self.viewController = [[[ViewController alloc] initWithAudioController:_audioController] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
