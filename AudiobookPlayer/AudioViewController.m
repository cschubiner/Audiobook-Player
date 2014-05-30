//
//  AudioViewController.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import "AudioViewController.h"

@interface AudioViewController ()

@property (strong, nonatomic) IBOutlet UISlider * volumeControl;
- (IBAction)adjustVolume:(id)sender;
- (IBAction)playAudio:(id)sender;
- (IBAction)stopAudio:(id)sender;
@property (strong, nonatomic) AVAudioSession * audioSession;
@property (strong, nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (assign) BOOL backgroundMusicPlaying;
@property (assign) BOOL backgroundMusicInterrupted;

@end

@implementation AudioViewController

-(void)viewDidLoad {
	[super viewDidLoad];
	[self configureAudioSession2];
	[self configureAudioPlayer];
}


- (void)tryPlayMusic {
	// If background music or other music is already playing, nothing more to do here
	if (self.backgroundMusicPlaying || [self.audioSession isOtherAudioPlaying]) {
		return;
	}
    
	// Play background music if no other music is playing and we aren't playing already
	//Note: prepareToPlay preloads the music file and can help avoid latency. If you don't
	//call it, then it is called anyway implicitly as a result of [self.backgroundMusicPlayer play];
	//It can be worthwhile to call prepareToPlay as soon as possible so as to avoid needless
	//delay when playing a sound later on.
	[self.backgroundMusicPlayer play];
	self.backgroundMusicPlaying = YES;
}

- (void)configureAudioSession {
	// Implicit initialization of audio session
	self.audioSession = [AVAudioSession sharedInstance];
    
	// Set category of audio session
	// See handy chart on pg. 46 of the Audio Session Programming Guide for what the categories mean
	// Not absolutely required in this example, but good to get into the habit of doing
	// See pg. 10 of Audio Session Programming Guide for "Why a Default Session Usually Isn't What You Want"
    
	NSError * setCategoryError = nil;
	if ([self.audioSession isOtherAudioPlaying]) { // mix sound effects with music already playing
		[self.audioSession setCategory:AVAudioSessionCategorySoloAmbient error:&setCategoryError];
		self.backgroundMusicPlaying = NO;
	}
	else {
		[self.audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
	}
    
	if (setCategoryError) {
		NSLog(@"Error setting category! %ld", (long)[setCategoryError code]);
	}
    
	NSError * activationError = nil;
	BOOL success = [self.audioSession setActive:YES error:&activationError];
	if (!success) { /* handle the error condition */
	}
    
}

-(void)configureAudioSession2 {
    //    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //    NSError *setCategoryError = nil;
    //    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    //    if (!success) { /* handle the error condition */ }
    //
    //    NSError *activationError = nil;
    //    success = [audioSession setActive:YES error:&activationError];
    //    if (!success) {
    //        NSLog(@"Error activating audio session");
    //    }
    //
	NSError * setCategoryErr = nil;
	NSError * activationErr  = nil;
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryErr];
	[[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
    
	self.audioSession = [AVAudioSession sharedInstance];
    
	NSError * audioError = nil;
	AVAudioSession * session = [AVAudioSession sharedInstance];
	if(![session setCategory:AVAudioSessionCategoryPlayback
                 withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&audioError]) {
		NSLog(@"[AppDelegate] Failed to setup audio session: %@", audioError);
	}
    
	[session setActive:YES error:&audioError];
    
    
}

- (void)configureAudioPlayer {
	// Create audio player with background music
	NSURL * backgroundMusicURL = [NSURL fileURLWithPath:self.audioPath];
	self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:nil];
	self.backgroundMusicPlayer.delegate = self; // We need this so we can restart after interruptions
	self.backgroundMusicPlayer.numberOfLoops = 1;
	[self.backgroundMusicPlayer prepareToPlay];
}


#pragma mark - AVAudioPlayerDelegate methods

- (void)audioPlayerBeginInterruption: (AVAudioPlayer *)player {
	//It is often not necessary to implement this method since by the time
	//this method is called, the sound has already stopped. You don't need to
	//stop it yourself.
	//In this case the backgroundMusicPlaying flag could be used in any
	//other portion of the code that needs to know if your music is playing.
    
	self.backgroundMusicInterrupted = YES;
	self.backgroundMusicPlaying = NO;
}

- (void)audioPlayerEndInterruption: (AVAudioPlayer *)player withOptions:(NSUInteger)flags {
	//Since this method is only called if music was previously interrupted
	//you know that the music has stopped playing and can now be resumed.
	[self tryPlayMusic];
	self.backgroundMusicInterrupted = NO;
}


- (IBAction)adjustVolume:(id)sender {
	if (self.backgroundMusicPlayer != nil) {
		self.backgroundMusicPlayer.volume = _volumeControl.value;
	}
}

- (IBAction)playAudio:(id)sender {
	[self tryPlayMusic];
}

- (IBAction)stopAudio:(id)sender {
	[self setBackgroundMusicPlaying:NO];
	[self.backgroundMusicPlayer stop];
}


-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player successfully:(BOOL)flag
{
}

-(void)audioPlayerDecodeErrorDidOccur: (AVAudioPlayer *)player error:(NSError *)error
{
}

@end
