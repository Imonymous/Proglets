//
//  ViewController.m
//  Proglets
//
//  Created by Iman Mukherjee on 1/29/14.
//  Copyright (c) 2014 Iman Mukherjee. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#define MAX_CHANNELS 4

@interface ViewController () {
    AudioFileID _audioUnitFile;
    AEChannelGroupRef _group;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Edit Button
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    m_thisPost = [appDelegate currentPostOnEdit];
    
    // Create an instance of the audio controller, set it up and start it running
    self.audioController = [[[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:YES] autorelease];
    _audioController.preferredBufferDuration = 0.005;
    [_audioController start:NULL];
    
    _group = [_audioController createChannelGroup];
    
    m_looping = false;
    
    _loopArray = [[NSMutableArray alloc] init];
    
    _trackArray = [[NSMutableArray alloc] init];
    
    // Add some data for demo purposes.
    [_trackArray addObject:@"1"];
    [_trackArray addObject:@"2"];
    [_trackArray addObject:@"3"];
    [_trackArray addObject:@"4"];
    
    // Init the picker view.
    _trackPicker = [[UIPickerView alloc] init];
    
    // Set the delegate and datasource. Don't expect picker view to work
    // correctly if you don't set it.
    [_trackPicker setDataSource: self];
    [_trackPicker setDelegate: self];
    
    NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *postNumber = [NSString stringWithFormat:@"%d", m_thisPost];
    NSString *postPath = [[documentsFolders objectAtIndex:0] stringByAppendingPathComponent:postNumber];
    
    if(postPath)
    {
        NSFileManager *filemgr;
        NSArray *filelist;
        
        filemgr =[NSFileManager defaultManager];
        filelist = [filemgr contentsOfDirectoryAtPath:postPath error:NULL];
        m_loopCounter = (int)[filelist count];
        if(m_loopCounter == 0)
        {
            m_loopCounter = 1;
        }
    }
    else
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error"
                                     message:[NSString stringWithFormat:@"Couldn't find the post."]
                                    delegate:nil
                           cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil] autorelease] show];
    }
}

- (void)record:(id)sender {
    
    if ( m_looping ) {
        [_audioController removeChannels:_loopArray];
        _playButton.selected = NO;
        m_looping = false;
        m_loopCounter = 1;
    }
    
    if ( _recorder ) {
        [_recorder finishRecording];
        [_audioController removeOutputReceiver:_recorder];
        [_audioController removeInputReceiver:_recorder];
        self.recorder = nil;
        _recordButton.selected = NO;
        [self.tableView reloadData];
    } else {
        
        if( m_loopCounter > MAX_CHANNELS )
        {
            m_loopCounter = 1;
            [_audioController removeChannels:_loopArray];
            [_loopArray removeAllObjects];
        }
                // Make a new Filename
        NSString *loop = [NSString stringWithFormat:@"%d/%d_%d.aiff", m_thisPost, m_thisPost, m_loopCounter];
        
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
        
        // Increment the loop count
        m_loopCounter++;
    }
}

- (void)play:(id)sender {
    
    if ( m_looping ) {
        [_audioController removeChannels:_loopArray];
        _playButton.selected = NO;
        m_looping = false;
        [_loopArray removeAllObjects];
    } else {
        
        for (int i = 1; i <= m_loopCounter; i++)
        {
            AEAudioFilePlayer *loop;
            
            // For each File
            NSString *loopFile = [NSString stringWithFormat:@"%d/%d_%d.aiff", m_thisPost, m_thisPost, i];
            
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch ( section ) {
        case 0:
            return 1;
        case 1:
            return 2;
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    switch ( indexPath.section ) {
        case 0: {
            return 250;
        }
        case 1: {
            switch ( indexPath.row ) {
                case 0: {
                    return 80;
                }
                case 1: {
                    return 120;
                }
            }
        }
        default: {
            return 250;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    static NSString *progCellIdentifier = @"progCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
    }
    
    // Configure the cell...
    
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch ( indexPath.section ) {
        case 0: {
            
            ProgletView *progCell = [tableView dequeueReusableCellWithIdentifier:progCellIdentifier];
            
            if ( progCell == nil ) {
                progCell = [[[ProgletView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"progCell"] autorelease];
            }
            
            [progCell loadFiles:m_thisPost];
            
            return progCell;
        }
        case 1: {
            
            switch ( indexPath.row ) {
                case 0: {
                    UIView *oscilView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, 80)];
                    oscilView.backgroundColor = [UIColor groupTableViewBackgroundColor];
                    
                    self.inputOscilloscope = [[TPOscilloscopeLayer alloc] initWithAudioController:_audioController];
                    _inputOscilloscope.frame = CGRectMake(0, 0, oscilView.bounds.size.width, 40);
                    [oscilView.layer addSublayer:_inputOscilloscope];
                    [_audioController addInputReceiver:_inputOscilloscope];
                    [_inputOscilloscope start];
                    
                    self.outputOscilloscope = [[[TPOscilloscopeLayer alloc] initWithAudioController:_audioController] autorelease];
                    _outputOscilloscope.frame = CGRectMake(0, 40, oscilView.bounds.size.width, 40);
                    [oscilView.layer addSublayer:_outputOscilloscope];
                    [_audioController addOutputReceiver:_outputOscilloscope];
                    [_outputOscilloscope start];

                    [cell addSubview:oscilView];
                    break;
                }
                case 1: {
                    UIView *controlsView = [[[UIView alloc] initWithFrame:CGRectMake(0, 10, cell.bounds.size.width, 100)] autorelease];
                    self.recordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
                    [_recordButton setTitle:@"Stop" forState:UIControlStateSelected];
                    [_recordButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
                    _recordButton.frame = CGRectMake(0, 0, ((controlsView.bounds.size.width) / 4), 20);
                    _recordButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
                    
                    self.uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [_uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
                    [_uploadButton setTitle:@"Stop" forState:UIControlStateSelected];
                    [_uploadButton addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchUpInside];
                    _uploadButton.frame = CGRectMake(0, 30, ((controlsView.bounds.size.width) / 4), 20);
                    _uploadButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;

                    
                    [_trackPicker setFrame:CGRectMake(CGRectGetMaxX(_recordButton.frame)+1, 0, ((controlsView.bounds.size.width-10) / 2), (controlsView.bounds.size.height - 1))];
                    
                    _trackPicker.showsSelectionIndicator = YES;
                    
                    [_trackPicker selectRow:0 inComponent:0 animated:YES];

                    self.playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [_playButton setTitle:@"Play" forState:UIControlStateNormal];
                    [_playButton setTitle:@"Stop" forState:UIControlStateSelected];
                    [_playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
                    _playButton.frame = CGRectMake(CGRectGetMaxX(_trackPicker.frame)+1, 0, ((controlsView.bounds.size.width-10) / 4), 20);
                    _playButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
                    
                    self.downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [_downloadButton setTitle:@"Download" forState:UIControlStateNormal];
                    [_downloadButton setTitle:@"Stop" forState:UIControlStateSelected];
                    [_downloadButton addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
                    _downloadButton.frame = CGRectMake(CGRectGetMaxX(_trackPicker.frame)+1, 30, ((controlsView.bounds.size.width-10) / 4), 20);
                    _downloadButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
                    
                    [controlsView addSubview:_trackPicker];
                    [controlsView addSubview:_recordButton];
                    [controlsView addSubview:_uploadButton];
                    [controlsView addSubview:_playButton];
                    [controlsView addSubview:_downloadButton];
                    
                    [cell addSubview:controlsView];
                    break;
                }
            }
            break;
        }
    }
    
    return cell;
}

// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_trackArray count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [_trackArray objectAtIndex: row];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [_trackArray objectAtIndex: row]);
    NSString* selected = [_trackArray objectAtIndex: row];
    m_loopCounter = selected.intValue;
}

- (void) upload : (id) sender
{
    NSString* className = [NSString stringWithFormat:@"proglet_%d", m_thisPost];
    PFObject *uploadObject = [PFObject objectWithClassName:className];
    
    NSString *postFullPath = [NSString stringWithFormat:@"%d/%d_%d.aiff", m_thisPost, m_thisPost, m_loopCounter];
    NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[documentsFolders objectAtIndex:0] stringByAppendingPathComponent:postFullPath];
    
    NSData *audioData = [NSData dataWithContentsOfFile:filePath];
    
    NSString *postFile = [NSString stringWithFormat:@"%d_%d.aiff", m_thisPost, m_loopCounter];
    
    PFFile *audioFile = [PFFile fileWithName:postFile data:audioData];
    
    uploadObject[@"audioFile"] = audioFile;
    
    [uploadObject saveInBackground];
}

- (void) download : (id) sender
{
    NSString* className = [NSString stringWithFormat:@"proglet_%d", m_thisPost];
    
    NSString *postFullPath = [NSString stringWithFormat:@"%d/%d_%d.aiff", m_thisPost, m_thisPost, m_loopCounter];
    NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[documentsFolders objectAtIndex:0] stringByAppendingPathComponent:postFullPath];
    
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKeyExists:@"audioFile"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            PFObject *downloadObject = [objects lastObject];
            PFFile *audioFile = downloadObject[@"audioFile"];
            NSString *playFilePath = [audioFile url];
            
            //play audiofile streaming
            self.avplayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:playFilePath]];
            self.avplayer.volume = 1.0f;
            [self.avplayer play];
            
            //download the file in a seperate thread.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"Downloading Started");
                NSURL  *url = [NSURL URLWithString:playFilePath];
                NSData *urlData = [NSData dataWithContentsOfURL:url];
                if ( urlData )
                {
                    //saving is done on main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [urlData writeToFile:filePath atomically:YES];
                        [self.tableView reloadData];
                        NSLog(@"File Saved !");
                    });
                }
                
            });
            
        } else {
            
            NSLog(@"error = %@", [error userInfo]);
        }
    }];
}

-(void)dealloc {
    
    if ( _reverb ) {
        [_audioController removeFilter:_reverb];
        self.reverb = nil;
    }
    
    self.audioController = nil;
    [_loopArray removeAllObjects];
    [_loopArray release];
    [_trackPicker release];
    [_trackArray release];
    [_audioController release];
    [_audioUnitPlayer release];
    [_avplayer release];
    [super dealloc];
}

- (IBAction)reverbSwitchChanged:(UISwitch*)sender {
    if ( sender.isOn ) {
        self.reverb = [[[AEAudioUnitFilter alloc] initWithComponentDescription:AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_Effect, kAudioUnitSubType_Reverb2) audioController:_audioController error:NULL] autorelease];
        
        AudioUnitSetParameter(_reverb.audioUnit, kReverb2Param_DryWetMix, kAudioUnitScope_Global, 0, 100.f, 0);
        
        [_audioController addFilter:_reverb];
    } else {
        [_audioController removeFilter:_reverb];
        self.reverb = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.hidesBackButton = NO;
    
    if(m_looping)
    {
        [self play:nil];
    }
    
    if(_recorder)
    {
        [self record:nil];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
