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
#import "MBProgressHUD.h"
#import "ProgletView.h"

@class AEAudioController;

@interface ViewController : UITableViewController <MBProgressHUDDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    int m_loopCounter;
    bool m_looping;
    int m_thisPost;
    
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
}

@property (nonatomic, retain) ProgletView* progletCellView;
@property (nonatomic, retain) AEAudioUnitFilter *reverb;
@property (nonatomic, retain) AEAudioController *audioController;
@property (nonatomic, retain) AEAudioUnitChannel *audioUnitPlayer;
@property (nonatomic, retain) TPOscilloscopeLayer *inputOscilloscope;
@property (nonatomic, retain) TPOscilloscopeLayer *outputOscilloscope;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) AERecorder *recorder;
@property (nonatomic, retain) UIButton *recordButton;
@property (nonatomic, retain) UIButton *playButton;
@property (nonatomic, retain) UIButton *uploadButton;
@property (nonatomic, retain) UIButton *downloadButton;
@property (nonatomic, retain) UIPickerView *trackPicker;
@property (nonatomic, retain) NSMutableArray *trackArray;
@property (nonatomic, retain) UIBarButtonItem *backButton;
@property (nonatomic, retain) NSMutableArray *loopArray;
@property (nonatomic, retain) AVPlayer *avplayer;
//@property (nonatomic, retain) UISwitch *reverbSwitch;

- (IBAction)reverbSwitchChanged:(UISwitch*)sender;

@end
