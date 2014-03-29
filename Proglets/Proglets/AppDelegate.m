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
    NSFileManager *filemgr;
    NSArray *filelist;
    int count;
    
    NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[documentsFolders objectAtIndex:0] stringByAppendingPathComponent:@""];
    
    filemgr =[NSFileManager defaultManager];
    filelist = [filemgr contentsOfDirectoryAtPath:path error:NULL];
    count = [filelist count];

    self.totalPosts = count;
    
    [Parse setApplicationId:@"inoNYTwJjHycE7QQqhc31Cv9n0GBafnBRkt9uNbu"
                  clientKey:@"7ttys0no0q3X23JIBoitnLR4iH69c6CKnxNePMPt"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    return YES;
}

@end
