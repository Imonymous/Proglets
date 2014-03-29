//
//  WaveformHelper.h
//  Proglets
//
//  Created by MusicUser on 3/20/14.
//  Copyright (c) 2014 GTCMT. All rights reserved.
//

#import <UIKit/UIKit.h>

#include <AVFoundation/AVFoundation.h>
#import "WaveSampleProvider.h"
#import "WaveSampleProviderDelegate.h"

@interface WaveformHelper : UIControl<WaveSampleProviderDelegate>
{
    UIActivityIndicatorView *progress;
	CGPoint* sampleData;
	int sampleLength;
	WaveSampleProvider *wsp;
	AVPlayer *player;
	float playProgress;
    
    UIColor *oranje;
	UIColor *gray;
	UIColor *lightgray;
	UIColor *darkgray;
	UIColor *white;
	UIColor *marker;
}

- (void) openAudioURL:(NSURL *)url;
- (void) playerItemDidReachEnd:(NSNotification *)notification;
- (void) pauseAudio;
- (void) play;
- (void) pause;

@end
