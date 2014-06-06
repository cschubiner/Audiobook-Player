//
//  AudioViewController.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import "AudioViewController.h"
#import "AudiobookPlayerAppDelegate.h"
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>


@interface AudioViewController ()

- (IBAction)playAudio:(id)sender;
- (IBAction)stopAudio:(id)sender;
@property (strong, nonatomic) AVAudioSession * audioSession;
@property (strong, nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (assign) BOOL backgroundMusicPlaying;
@property (assign) BOOL backgroundMusicInterrupted;
@property (weak, nonatomic) IBOutlet UISlider * seekSlider;

@end

@implementation AudioViewController

-(void)viewDidLoad {
	[super viewDidLoad];
	[self configureAudioSession];
	[self configureAudioPlayer];
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	if (self != delegate.currentAudioViewController) {
        [delegate.currentAudioViewController recordCurrentPosition];
        [delegate.managedObjectContext save:nil];
		[[delegate.currentAudioViewController backgroundMusicPlayer]stop];
//		[delegate.currentAudioViewController setBackgroundMusicPlayer:nil];
		[delegate setCurrentAudioViewController:self];
	}
    
	[self.backgroundMusicPlayer setCurrentTime:self.song.currentPosition.doubleValue];
	[self tryPlayMusic];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
    [self recordCurrentPosition];
    [delegate.managedObjectContext save:nil];
}

- (IBAction)slide {
	self.backgroundMusicPlayer.currentTime = self.seekSlider.value;
    [self recordCurrentPosition];
}

-(void)recordCurrentPosition {
//	[((AudiobookPlayerAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext performBlock :^{
        self.song.currentPosition = [NSNumber numberWithDouble:self.backgroundMusicPlayer.currentTime];
//    }];
}

- (void)updateTime:(NSTimer *)timer {
	self.seekSlider.value = self.backgroundMusicPlayer.currentTime;
    [self recordCurrentPosition];
}

- (void)tryPlayMusic {
	if (self.backgroundMusicPlaying || [self.audioSession isOtherAudioPlaying]) {
		return;
	}
    
	[self.backgroundMusicPlayer play];
	self.backgroundMusicPlaying = YES;
    
	Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
	if (playingInfoCenter) {
		NSMutableDictionary * songInfo = [[NSMutableDictionary alloc] init];
		//        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: [UIImage imagedNamed:@"AlbumArt"]];
        
		[songInfo setObject:self.song.title forKey:MPMediaItemPropertyTitle];
//		[songInfo setObject:@"Audio Author" forKey:MPMediaItemPropertyArtist];
//		[songInfo setObject:@"Audio Album" forKey:MPMediaItemPropertyAlbumTitle];
		//        [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
		[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
	}
    
	self.seekSlider.maximumValue = [self.backgroundMusicPlayer duration];
	[self updateTime:nil];
    
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
}

-(void)configureAudioSession {
	[[AVAudioSession sharedInstance] setDelegate:self];
	self.audioSession = [AVAudioSession sharedInstance];
}

- (void)configureAudioPlayer {
	// Create audio player with background music
	NSURL * backgroundMusicURL = [NSURL fileURLWithPath:self.song.path];
	self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:nil];
	self.backgroundMusicPlayer.delegate = self; // We need this so we can restart after interruptions
	self.backgroundMusicPlayer.numberOfLoops = 1;
	[self.backgroundMusicPlayer prepareToPlay];
}


#pragma mark - AVAudioPlayerDelegate methods

- (void)audioPlayerBeginInterruption: (AVAudioPlayer *)player {
	self.backgroundMusicInterrupted = YES;
	self.backgroundMusicPlaying = NO;
}

- (void)audioPlayerEndInterruption: (AVAudioPlayer *)player withOptions:(NSUInteger)flags {
	[self tryPlayMusic];
	self.backgroundMusicInterrupted = NO;
}


- (IBAction)playAudio:(id)sender {
	[self tryPlayMusic];
}

-(IBAction)playPauseAudio:(id)sender {
	if (self.backgroundMusicPlaying)
		[self stopAudio:nil];
	else
		[self playAudio:nil];
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
