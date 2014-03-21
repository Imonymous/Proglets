//
//  ProgletView.h
//  Proglets
//
//  Created by MusicUser on 3/19/14.
//  Copyright (c) 2014 GTCMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaveformHelper.h"

@interface ProgletView : UITableViewCell

@property (retain, nonatomic) IBOutlet WaveformHelper *wfv;

@property (nonatomic, retain) IBOutlet UIButton *loadButton;

-(IBAction) loadAudio:(id)sender;

@end
