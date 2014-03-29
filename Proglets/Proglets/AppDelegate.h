//
//  AppDelegate.h
//  Proglets
//
//  Created by Iman Mukherjee on 3/3/14.
//  Copyright (c) 2014 GTCMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (retain, nonatomic) UIWindow *window;

@property int totalPosts;

@property int currentPostOnEdit;

@end
