//
//  AppDelegate.h
//  Proglets
//
//  Created by Iman Mukherjee on 3/3/14.
//  Copyright (c) 2014 GTCMT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;
@class AEAudioController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) ViewController *viewController;
@property (retain, nonatomic) AEAudioController *audioController;
@end
