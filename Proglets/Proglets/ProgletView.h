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
{
    bool isPlayingAll;
}

@property (nonatomic, retain) IBOutlet WaveformHelper *wfv1;
@property (nonatomic, retain) IBOutlet WaveformHelper *wfv2;
@property (nonatomic, retain) IBOutlet WaveformHelper *wfv3;
@property (nonatomic, retain) IBOutlet WaveformHelper *wfv4;
//@property (nonatomic, retain) IBOutlet UILongPressGestureRecognizer *longPress;
@property (nonatomic, retain) IBOutlet UIButton *playAll;

- (void)loadFiles:(NSInteger)post;

@end
