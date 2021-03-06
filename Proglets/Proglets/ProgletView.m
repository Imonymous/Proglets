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
        
    }
    return self;
}

- (void)dealloc {
    
    [_wfv1 pause];
    [_wfv2 pause];
    [_wfv3 pause];
    [_wfv4 pause];
    
	[_wfv1 release];
    [_wfv2 release];
    [_wfv3 release];
    [_wfv4 release];
    
	[super dealloc];
}

- (void)loadFiles:(NSInteger)post {
    
    NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *postNumber = [NSString stringWithFormat:@"%d", post];
    NSString *postPath = [[documentsFolders objectAtIndex:0] stringByAppendingPathComponent:postNumber];
    
    if(postPath)
    {
        NSFileManager *filemgr;
        NSArray *filelist;
        int count;
        
        filemgr =[NSFileManager defaultManager];
        filelist = [filemgr contentsOfDirectoryAtPath:postPath error:NULL];
        count = [filelist count];
        
        if(count > 0) {
            
            for (int i = 1; i <= count; i++)
            {
                NSString *trackNumber = [NSString stringWithFormat:@"%d_%d.aiff", post, i];
                NSString *path = [postPath stringByAppendingPathComponent:trackNumber];
                NSURL *songURL = [NSURL fileURLWithPath:path];
                switch(i)
                {
                    case 1: {
                        [_wfv1 openAudioURL:songURL];
                        break;
                    }
                    case 2: {
                        [_wfv2 openAudioURL:songURL];
                        break;
                    }
                    case 3: {
                        [_wfv3 openAudioURL:songURL];
                        break;
                    }
                    case 4: {
                        [_wfv4 openAudioURL:songURL];
                        break;
                    }
                }
            }
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Audio !"
                                                            message: @"You should add something!"
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }
}

- (IBAction)playAll:(id)sender {
    
        [_wfv1 pauseAudio];
        [_wfv2 pauseAudio];
        [_wfv3 pauseAudio];
        [_wfv4 pauseAudio];
        
        NSLog(@"Playing All");
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
