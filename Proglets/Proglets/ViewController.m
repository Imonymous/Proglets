//
//  ViewController.m
//  Proglets
//
//  Created by Iman Mukherjee on 1/29/14.
//  Copyright (c) 2014 Iman Mukherjee. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TheAmazingAudioEngine.h"
#import "TPOscilloscopeLayer.h"
#import "AERecorder.h"

@interface ViewController () {
    AudioFileID _audioUnitFile;
    AEChannelGroupRef _group;
}

@property (nonatomic, retain) AEAudioController *audioController;
@property (nonatomic, retain) AEAudioUnitChannel *audioUnitPlayer;
@property (nonatomic, retain) TPOscilloscopeLayer *inputOscilloscope;
@property (nonatomic, retain) TPOscilloscopeLayer *outputOscilloscope;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) AERecorder *recorder;
@property (nonatomic, retain) UIButton *recordButton;
@property (nonatomic, retain) UIButton *playButton;
@property (nonatomic, retain) NSMutableArray *loopArray;

@end

@implementation ViewController

- (id) initWithAudioController:(AEAudioController*)audioController
{
    if ( !(self = [super initWithStyle:UITableViewStyleGrouped]) ) return nil;
    
    self.audioController = audioController;
    
    // Create a group for loop1, loop2 and oscillator
    
    _group = [_audioController createChannelGroup];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 100)];
    headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.inputOscilloscope = [[TPOscilloscopeLayer alloc] initWithAudioController:_audioController];
    _inputOscilloscope.frame = CGRectMake(0, 0, headerView.bounds.size.width, 80);
    [headerView.layer addSublayer:_inputOscilloscope];
    [_audioController addInputReceiver:_inputOscilloscope];
    [_inputOscilloscope start];
    
    self.outputOscilloscope = [[[TPOscilloscopeLayer alloc] initWithAudioController:_audioController] autorelease];
    _outputOscilloscope.frame = CGRectMake(0, 0, headerView.bounds.size.width, 380);
    [headerView.layer addSublayer:_outputOscilloscope];
    [_audioController addOutputReceiver:_outputOscilloscope];
    [_outputOscilloscope start];
    
    self.tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 80)] autorelease];
    self.recordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [_recordButton setTitle:@"Stop" forState:UIControlStateSelected];
    [_recordButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    _recordButton.frame = CGRectMake(20, 10, ((footerView.bounds.size.width-50) / 2), footerView.bounds.size.height - 20);
    _recordButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    [_playButton setTitle:@"Stop" forState:UIControlStateSelected];
    [_playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    _playButton.frame = CGRectMake(CGRectGetMaxX(_recordButton.frame)+10, 10, ((footerView.bounds.size.width-50) / 2), footerView.bounds.size.height - 20);
    _playButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [footerView addSubview:_recordButton];
    [footerView addSubview:_playButton];
    
    self.tableView.tableFooterView = footerView;
    
    m_loopCounter = -1;
    m_looping = false;
    _loopArray = [[NSMutableArray alloc] init];

}

- (void)record:(id)sender {
    
    if ( m_looping ) {
        [_audioController removeChannels:_loopArray];
        _playButton.selected = NO;
        m_looping = false;
        m_loopCounter = 0;
    }
    
    if ( _recorder ) {
        [_recorder finishRecording];
        [_audioController removeOutputReceiver:_recorder];
        [_audioController removeInputReceiver:_recorder];
        self.recorder = nil;
        _recordButton.selected = NO;
    } else {
        
        if( m_loopCounter >= 4 )
        {
            m_loopCounter = -1;
            [_audioController removeChannels:_loopArray];
        }
        
        // Increment the loop count
        m_loopCounter++;
        
        // Make a new Filename
        NSString *loop = [NSString stringWithFormat:@"%d.aiff", m_loopCounter];
        
        self.recorder = [[[AERecorder alloc] initWithAudioController:_audioController] autorelease];
        NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *path = [[documentsFolders objectAtIndex:0] stringByAppendingPathComponent:loop];
        NSError *error = nil;
        if ( ![_recorder beginRecordingToFileAtPath:path fileType:kAudioFileAIFFType error:&error] ) {
            [[[[UIAlertView alloc] initWithTitle:@"Error"
                                         message:[NSString stringWithFormat:@"Couldn't start recording: %@", [error localizedDescription]]
                                        delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:@"OK", nil] autorelease] show];
            self.recorder = nil;
            return;
        }
        
        _recordButton.selected = YES;
        
        // Create an audio unit channel (a file player)
        self.audioUnitPlayer = [[[AEAudioUnitChannel alloc] initWithComponentDescription:AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer)
                                                                         audioController:_audioController
                                                                                   error:NULL] autorelease];

        
        [_audioController addOutputReceiver:_recorder];
        [_audioController addInputReceiver:_recorder];
    }
}

- (void)play:(id)sender {
    
    if ( m_looping ) {
        [_audioController removeChannels:_loopArray];
        _playButton.selected = NO;
        m_looping = false;
    } else {
        
        for (int i = 0; i <= m_loopCounter; i++)
        {
            AEAudioFilePlayer *loop;
            
            // For each File
            NSString *loopFile = [NSString stringWithFormat:@"%d.aiff", i];
            
            NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [[documentsFolders objectAtIndex:0] stringByAppendingPathComponent:loopFile];
            
            if ( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) return;
            
            NSError *error = nil;
            loop = [AEAudioFilePlayer audioFilePlayerWithURL:[NSURL fileURLWithPath:path] audioController:_audioController error:&error];
            
            if ( !loop ) {
                [[[[UIAlertView alloc] initWithTitle:@"Error"
                                             message:[NSString stringWithFormat:@"Couldn't start playback: %@", [error localizedDescription]]
                                            delegate:nil
                                   cancelButtonTitle:nil
                                   otherButtonTitles:@"OK", nil] autorelease] show];
                return;
            }
            
            loop.volume = 1.0;
            loop.channelIsMuted = NO;
            loop.loop = YES;
            
            loop.removeUponFinish = YES;
            loop.completionBlock = ^{
                _playButton.selected = NO;
            };

            [_loopArray addObject:loop];
        }
    
        // Create an audio unit channel (a file player)
        self.audioUnitPlayer = [[[AEAudioUnitChannel alloc] initWithComponentDescription:AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer)
                                                                         audioController:_audioController
                                                                                   error:NULL] autorelease];
        
        [_audioController addChannels:_loopArray toChannelGroup:_group];
        
        // Finally, add the audio unit player
        [_audioController addChannels:[NSArray arrayWithObjects:_audioUnitPlayer, nil]];
        
        _playButton.selected = YES;
        
        m_looping = true;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
