//
//  ProgletView.m
//  Proglets
//
//  Created by MusicUser on 3/19/14.
//  Copyright (c) 2014 GTCMT. All rights reserved.
//

#import "ProgletView.h"

@implementation ProgletView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
        // Initialization code
//        NSString *loopFile = [NSString stringWithFormat:@"0.aiff"];
//        NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *path = [[documentsFolders objectAtIndex:0] stringByAppendingPathComponent:loopFile];
    
    }
    return self;
}

- (void)dealloc {
	[_wfv release];
	[super dealloc];
}

-(IBAction) loadAudio:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp3"];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL *songURL = [NSURL fileURLWithPath:path];
        [_wfv openAudioURL:songURL];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Audio !"
                                                        message: @"You should add a sample.mp3 file to the project before test it."
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
}
*/

@end
