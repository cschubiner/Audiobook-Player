//
//  AudioViewController.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import "AudioViewController.h"
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>


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

-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
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
    
	Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
	if (playingInfoCenter) {
		NSMutableDictionary * songInfo = [[NSMutableDictionary alloc] init];
		//        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: [UIImage imagedNamed:@"AlbumArt"]];
        
		[songInfo setObject:@"Audio Title" forKey:MPMediaItemPropertyTitle];
		[songInfo setObject:@"Audio Author" forKey:MPMediaItemPropertyArtist];
		[songInfo setObject:@"Audio Album" forKey:MPMediaItemPropertyAlbumTitle];
		//        [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
		[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
	}
}

-(void)configureAudioSession2 {
    
	NSError * setCategoryErr = nil;
	NSError * activationErr  = nil;
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryErr];
	[[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
    
    
	NSError * audioError = nil;
	AVAudioSession * session = [AVAudioSession sharedInstance];
	if(![session setCategory:AVAudioSessionCategoryPlayback
                 withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&audioError]) {
		NSLog(@"[AppDelegate] Failed to setup audio session: %@", audioError);
	}
	else
		[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
	[[AVAudioSession sharedInstance] setDelegate:self];
    
	[session setActive:YES error:&audioError];
    
	self.audioSession = [AVAudioSession sharedInstance];
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
