//
//  WaveformHelper.m
//  Proglets
//
//  Created by MusicUser on 3/20/14.
//  Copyright (c) 2014 GTCMT. All rights reserved.
//

#import "WaveformHelper.h"

@implementation WaveformHelper


// View-related
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self) {
		[self initView];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self initView];
    }
    return self;
}

- (void) initView
{
	playProgress = 0.0;
	progress = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
	progress.frame = [self progressRect];
	[self addSubview:progress];
	[progress setHidden:TRUE];
    
    green = [[UIColor colorWithRed:143.0/255.0 green:196.0/255.0 blue:72.0/255.0 alpha:1.0]retain];
	gray = [[UIColor colorWithRed:64.0/255.0 green:63.0/255.0 blue:65.0/255.0 alpha:1.0]retain];
	lightgray = [[UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1.0]retain];
	darkgray = [[UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:48.0/255.0 alpha:1.0]retain];
	white = [[UIColor whiteColor]retain];
	marker = [[UIColor colorWithRed:242.0/255.0 green:147.0/255.0 blue:0.0/255.0 alpha:1.0]retain];
}


- (void) openAudioURL:(NSURL *)url
{
	if(player != nil) {
		[player pause];
		[player release];
		player = nil;
	}
	[self releaseSample];
	[self setNeedsDisplay];
	[progress setHidden:FALSE];
	[progress startAnimating];
	[wsp release];
	wsp = [[WaveSampleProvider alloc]initWithURL:url];
    wsp.delegate = self;
	[wsp createSampleData];
}

#pragma mark Drawing
- (BOOL) isOpaque
{
	return NO;
}

// Rectangles
- (CGRect) progressRect
{
	return CGRectMake(10, 90, 0, 50);
}

- (CGRect) waveRect
{
	return CGRectMake(30, 10, 225, 30);
}

- (CGRect) playButton
{
	return CGRectMake(5, 10, 20, 30);
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGContextRef cx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(cx);
	
	CGContextSetFillColorWithColor(cx, [UIColor clearColor].CGColor);
	CGContextFillRect(cx, self.bounds);
	
	[self drawRoundRect:self.bounds fillColor:green strokeColor:green radius:8.0 lineWidht:2.0];

	CGRect waveRect = [self waveRect];
	[self drawRoundRect:waveRect fillColor:lightgray strokeColor:lightgray radius:4.0 lineWidht:2.0];
	
	CGRect playButton = [self playButton];
	[self drawRoundRect:playButton fillColor:lightgray strokeColor:darkgray radius:4.0 lineWidht:2.0];
	
	if(sampleLength > 0) {
        
		CGMutablePathRef halfPath = CGPathCreateMutable();
		CGPathAddLines( halfPath, NULL,sampleData, sampleLength); // magic!
		
		CGMutablePathRef path = CGPathCreateMutable();
		
		double xscale = (CGRectGetWidth(waveRect)-12.0) / (float)sampleLength;
		// Transform to fit the waveform ([0,1] range) into the vertical space
		// ([halfHeight,height] range)
		double halfHeight = floor( CGRectGetHeight(waveRect) / 2.0 );//waveRect.size.height / 2.0;
		CGAffineTransform xf = CGAffineTransformIdentity;
		xf = CGAffineTransformTranslate( xf, waveRect.origin.x+6, halfHeight + waveRect.origin.y);
		xf = CGAffineTransformScale( xf, xscale, -(halfHeight-6) );
		CGPathAddPath( path, &xf, halfPath );
		
		// Transform to fit the waveform ([0,1] range) into the vertical space
		// ([0,halfHeight] range), flipping the Y axis
		xf = CGAffineTransformIdentity;
		xf = CGAffineTransformTranslate( xf, waveRect.origin.x+6, halfHeight + waveRect.origin.y);
		xf = CGAffineTransformScale( xf, xscale, (halfHeight-6));
		CGPathAddPath( path, &xf, halfPath );
		
		CGPathRelease( halfPath ); // clean up!
		// Now, path contains the full waveform path.
		CGContextRef cx = UIGraphicsGetCurrentContext();
		
		[darkgray set];
		CGContextAddPath(cx, path);
		CGContextStrokePath(cx);
		
		// gauge draw
		if(playProgress > 0.0) {
			CGRect clipRect = waveRect;
			clipRect.size.width = (clipRect.size.width - 12) * playProgress;
			clipRect.origin.x = clipRect.origin.x + 6;
			CGContextClipToRect(cx,clipRect);
			
			[marker setFill];
			CGContextAddPath(cx, path);
			CGContextFillPath(cx);
			CGContextClipToRect(cx,waveRect);
			[darkgray set];
			CGContextAddPath(cx, path);
			CGContextStrokePath(cx);
		}
		CGPathRelease(path); // clean up!
	}
	[[UIColor clearColor] setFill];
	CGContextRestoreGState(cx);
	
}

- (void) drawRoundRect:(CGRect)bounds fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor radius:(CGFloat)radius lineWidht:(CGFloat)lineWidth
{
	CGRect rrect = CGRectMake(bounds.origin.x+(lineWidth/2), bounds.origin.y+(lineWidth/2), bounds.size.width - lineWidth, bounds.size.height - lineWidth);
	
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	CGContextRef cx = UIGraphicsGetCurrentContext();
	
	CGContextMoveToPoint(cx, minx, midy);
	CGContextAddArcToPoint(cx, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(cx, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(cx, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(cx, minx, maxy, minx, midy, radius);
	CGContextClosePath(cx);
	
	CGContextSetStrokeColorWithColor(cx, strokeColor.CGColor);
	CGContextSetFillColorWithColor(cx, fillColor.CGColor);
	CGContextDrawPath(cx, kCGPathFillStroke);
}


// Player-related
- (void) startAudio
{
	if(wsp.status == LOADED) {
		player = [[AVPlayer alloc] initWithURL:wsp.audioURL];
		CMTime tm = CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC);
		[player addPeriodicTimeObserverForInterval:tm queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
			Float64 duration = CMTimeGetSeconds(player.currentItem.duration);
			Float64 currentTime = CMTimeGetSeconds(player.currentTime);
//			int dmin = duration / 60;
//			int dsec = duration - (dmin * 60);
//			int cmin = currentTime / 60;
//			int csec = currentTime - (cmin * 60);
			
			playProgress = currentTime/duration;
			[self setNeedsDisplay];
		}];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[player currentItem]];
	}
}

- (void) pauseAudio
{
	if(wsp) {
		if(player == nil) {
			[self startAudio];
			[player play];
		} else {
			if(player.rate == 0.0) {
				[player play];
			} else {
				[player pause];
			}
		}
	}
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero]; //set to 00:00
    [player play]; // Looping
}

- (void) releaseSample
{
	if(sampleData != nil) {
		free(sampleData);
		sampleData = nil;
		sampleLength = 0;
	}
}

// Samples-related
- (void) sampleProcessed:(WaveSampleProvider *)provider
{
	if(wsp.status == LOADED) {
		int sdl = 0;
		//		float *sd = [wsp dataForResolution:[self waveRect].size.width lenght:&sdl];
		float *sd = [wsp dataForResolution:8000 lenght:&sdl];
		[self setSampleData:sd length:sdl];
		playProgress = 0.0;
//		int dmin = wsp.minute;
//		int dsec = wsp.sec;
		[self startAudio];
	}
}

- (void) setSampleData:(float *)theSampleData length:(int)length
{
	[progress setHidden:FALSE];
	[progress startAnimating];
	sampleLength = 0;
	
	length += 2;
	CGPoint *tempData = (CGPoint *)calloc(sizeof(CGPoint),length);
	tempData[0] = CGPointMake(0.0,0.0);
	tempData[length-1] = CGPointMake(length-1,0.0);
	for(int i = 1; i < length-1;i++) {
		tempData[i] = CGPointMake(i, theSampleData[i]);
	}
	
	CGPoint *oldData = sampleData;
	
	sampleData = tempData;
	sampleLength = length;
	
	if(oldData != nil) {
		free(oldData);
	}
	
	free(theSampleData);
	[progress setHidden:TRUE];
	[progress stopAnimating];
	[self setNeedsDisplay];
}

#pragma mark Touch Handling
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint local_point = [touch locationInView:self];
	CGRect wr = [self waveRect];
	wr.size.width = (wr.size.width - 12);
	wr.origin.x = wr.origin.x + 6;
    if(CGRectContainsPoint([self playButton],local_point)) {
		NSLog(@"Play/Pause touched");
		[self pauseAudio];
    }
	if(CGRectContainsPoint(wr,local_point) && player != nil) {
		CGFloat x = local_point.x - wr.origin.x;
		float sel = x / wr.size.width;
		Float64 duration = CMTimeGetSeconds(player.currentItem.duration);
		float timeSelected = duration * sel;
		CMTime tm = CMTimeMakeWithSeconds(timeSelected, NSEC_PER_SEC);
		[player seekToTime:tm];
		NSLog(@"Clicked time : %f",timeSelected);
	}
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
	[self releaseSample];
	[player pause];
	[player release];
	[green release];
	[gray release];
	[lightgray release];
	[darkgray release];
	[white release];
	[marker release];
	[wsp release];
	[super dealloc];
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
