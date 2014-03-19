//
//  ViewController.h
//  Proglets
//
//  Created by Iman Mukherjee on 1/29/14.
//  Copyright (c) 2014 Iman Mukherjee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TheAmazingAudioEngine.h"
#import "TPOscilloscopeLayer.h"
#import "AERecorder.h"

@class AEAudioController;

@interface ViewController : UITableViewController
{
    int m_loopCounter;
    bool m_looping;
}


@end
