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
@property (weak, nonatomic) IBOutlet CPSlider * seekSlider;
@property (weak, nonatomic) IBOutlet UILabel * gestureLabel;
@property (weak, nonatomic) Song * song;
@property (weak, nonatomic) IBOutlet UILabel * currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel * durationLabel;

@property (weak, nonatomic) IBOutlet UIImageView * backgroundImageView;

#define PI 3.1415926535897932384626
@property (weak, nonatomic) IBOutlet UIButton * playButton;
@property (weak, nonatomic) IBOutlet UIButton * nextButton;
@property (weak, nonatomic) IBOutlet UIButton * prevButton;

@end

BOOL isSliding;

@implementation AudioViewController

- (void)setupSlider {
	[self.seekSlider setDelegate:self];
	self.seekSlider.scrubbingSpeedPositions = [NSArray arrayWithObjects:
	                                           [NSNumber numberWithInt:0],
	                                           [NSNumber numberWithInt:self.view.frame.size.height / 6.3],
	                                           [NSNumber numberWithInt:2 * self.view.frame.size.height / 6],
	                                           [NSNumber numberWithInt:3 * self.view.frame.size.height / 6], nil];
    
	[self.seekSlider addTarget:self
                        action:@selector(sliderDidEndSliding:)
              forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
	[self.seekSlider addTarget:self
                        action:@selector(sliderDidStartSliding:)
              forControlEvents:(UIControlEventTouchDragInside | UIControlEventTouchDragOutside)];
}

- (void)sliderDidStartSliding:(NSNotification *)notification {
	isSliding = true;
}

- (void)sliderDidEndSliding:(NSNotification *)notification {
	isSliding = false;
	self.backgroundMusicPlayer.currentTime = self.seekSlider.value;
	if (musicWasPlaying)
		[self.backgroundMusicPlayer play];
    
	canChangePlayingState = true;
}

-(Song *)getSong {
	return self.song;
}

-(void)viewDidLoad {
	[super viewDidLoad];
	self.song = [self.songs objectAtIndex:self.firstSongIndex];
	NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSInteger colorScheme = [standardUserDefaults integerForKey:@"colorScheme"];
	if (colorScheme == 0) {
		self.backgroundImageView.image = [UIImage imageNamed:@"backgroundspace.png"];
		self.currentTimeLabel.textColor = [UIColor whiteColor];
		self.durationLabel.textColor = [UIColor whiteColor];
		[self.playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.prevButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	else {
		self.backgroundImageView.image = [UIImage imageNamed:@"backgroundLogin.png"];
	}
    
	[self configureAudioSession];
	[self configureAudioPlayer];
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	if (self != delegate.currentAudioViewController) {
		delegate.currentAudioViewController.getSong.isLastPlayed = [NSNumber numberWithBool:FALSE];
		[delegate.currentAudioViewController recordCurrentPosition];
		[((AudiobookPlayerAppDelegate*)[UIApplication sharedApplication].delegate)saveContext];
		[[delegate.currentAudioViewController backgroundMusicPlayer]stop];
		[delegate setCurrentAudioViewController:self];
	}
    
	[self.backgroundMusicPlayer setCurrentTime:self.song.currentPosition.doubleValue];
	[self setupSlider];
	[self tryPlayMusic];
}


-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self recordCurrentPosition];
	[((AudiobookPlayerAppDelegate*)[UIApplication sharedApplication].delegate)saveContext];
}

-(void)slider:(CPSlider *)slider didChangeToSpeed:(CGFloat)speed whileTracking:(BOOL)tracking {
	[self.gestureLabel setText:[NSString stringWithFormat:@"Scrubbing at %.02fx", speed]];
	[self flashGestureLabelWithDuration:2];
}

BOOL musicWasPlaying = false;
BOOL canChangePlayingState = true;
- (IBAction)slide {
	self.currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", ((int)self.seekSlider.value / 60), ((int)self.seekSlider.value % 60)];
	if (canChangePlayingState)
		musicWasPlaying = self.backgroundMusicPlayer.isPlaying;
    
	canChangePlayingState = false;
	[self.backgroundMusicPlayer stop];
    
	if (self.seekSlider.currentScrubbingSpeed >= .999) {
		[self.gestureLabel setText:[NSString stringWithFormat:@"Slide down to scrub slower"]];
		[self flashGestureLabelWithDuration:2];
	}
}

- (void)updateCurrentTimeLabel {
	self.currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", ((int)self.seekSlider.value / 60), ((int)self.seekSlider.value % 60)];
}

double skipToTime = -1;
bool shouldSkipCrossTrack;

- (void)skipWithDuration:(CGFloat)skipDuration {
	[self.gestureLabel setText:[NSString stringWithFormat:@"%@ %d secs", skipDuration >= 0 ? @"Jumping" :@"Reversing", abs((int)skipDuration)]];
	[self flashGestureLabel];
    shouldSkipCrossTrack = false;
    double newTime = self.backgroundMusicPlayer.currentTime + skipDuration;
    if (newTime > self.backgroundMusicPlayer.duration) {
        shouldSkipCrossTrack = true;
        skipToTime = newTime - self.backgroundMusicPlayer.duration;
        self.backgroundMusicPlayer.currentTime += skipDuration;
    	[self recordCurrentPosition];
        [self nextSong:nil];
    }
    else if (newTime < 0) {
        shouldSkipCrossTrack = true;
        skipToTime = newTime;
        self.backgroundMusicPlayer.currentTime += skipDuration;
    	[self recordCurrentPosition];
        [self previousSong:nil];
    }
    else {
    	self.backgroundMusicPlayer.currentTime += skipDuration;
    	self.seekSlider.value += skipDuration;
    	[self updateCurrentTimeLabel];
    	[self recordCurrentPosition];
    }
}

- (IBAction)didPan:(UIPanGestureRecognizer *)sender {
	static CGPoint startingPoint;
	static CGPoint endPoint;
    
	if (sender.state == UIGestureRecognizerStateBegan) {
		startingPoint  = [sender locationInView:sender.view];
	}
	else if (sender.state == UIGestureRecognizerStateEnded) {
		endPoint = [sender locationInView:sender.view];
		CGFloat angle = atan2(startingPoint.y - endPoint.y, endPoint.x - startingPoint.x);
		NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
		BOOL isPanMode = [standardUserDefaults integerForKey:@"panMode"] == 0;
		if (isPanMode) {
			const CGFloat maxSecondsToSkip = 29.5;
			CGFloat skipDuration = -(fabsf(angle) - PI / 2) * maxSecondsToSkip * 30.0 / 7.0 / PI / 2;
			[self skipWithDuration:skipDuration];
		}
		else {
			//we're in swipe mode
			CGFloat angle2 =fabsf(angle) - PI / 2;
			if (angle2 < -1)
				[self skipWithDuration:25];
			else if (angle2 > 1)
				[self skipWithDuration:-20];
			else {
				//handle up/down swipes
				if (angle > 1)
					[self skipWithDuration:-7];
				else if (angle < -1)
					[self skipWithDuration:7];
			}
		}
	}
}

- (IBAction)didTapView:(id)sender {
	[self playPauseAudio:nil];
	[self recordCurrentPosition];
}


-(void)recordCurrentPosition {
	static double lastPos = -5;
	if (lastPos == -5 || self.backgroundMusicPlayer.currentTime != lastPos) {
		[self recordCurrNoSave];
		[((AudiobookPlayerAppDelegate*)[UIApplication sharedApplication].delegate)saveContext];
	}
	else
		DebugLog(@"not recording");
    
	lastPos = self.backgroundMusicPlayer.currentTime;
}

-(void)recordCurrNoSave {
	self.song.currentPosition = [NSNumber numberWithDouble:self.backgroundMusicPlayer.currentTime];
	DebugLog(@"recorded position: %@", self.song.currentPosition);
}

- (void)updateTime:(NSTimer *)timer {
	DebugLog(@"aa");
	if (isSliding)
		return;
    
	DebugLog(@"ab");
	self.seekSlider.value = self.backgroundMusicPlayer.currentTime;
	DebugLog(@"ac");
	[self updateCurrentTimeLabel];
	DebugLog(@"ad");
	[self recordCurrentPosition];
	DebugLog(@"af");
}

- (void)tryPlayMusic {
	if (self.backgroundMusicPlaying || [self.audioSession isOtherAudioPlaying]) {
		return;
	}
    
	//	BOOL playSuccess =
	[self.backgroundMusicPlayer play];
	self.backgroundMusicPlaying = YES;
    
	if (fabsf(self.song.duration.doubleValue - self.song.currentPosition.doubleValue) < 1) {
		//if the song ended or is about to end, we'll restart it
		self.backgroundMusicPlayer.currentTime = 0;
	}
    
	self.song.isLastPlayed = [NSNumber numberWithBool:TRUE];
	self.durationLabel.text = [NSString stringWithFormat:@"%d:%02d", ((int)self.song.duration.floatValue / 60), ((int)self.song.duration.floatValue % 60)];
    
    
	Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
	if (playingInfoCenter) {
		NSMutableDictionary * songInfo = [[NSMutableDictionary alloc] init];
		//        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: [UIImage imagedNamed:@"AlbumArt"]];
        
		[songInfo setObject:self.song.title forKey:MPMediaItemPropertyTitle];
		[songInfo setObject:@"Audiobook Player" forKey:MPMediaItemPropertyArtist];
		//		[songInfo setObject:@"Audio Album" forKey:MPMediaItemPropertyAlbumTitle];
		//        [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
		[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
	}
    
	[self.navigationItem setTitle:self.song.title];
    
	self.seekSlider.maximumValue = [self.backgroundMusicPlayer duration];
	[self updateTime:nil];
    
	static NSTimer * timer;
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
    
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
}

-(void)configureAudioSession {
	[[AVAudioSession sharedInstance] setDelegate:self];
	self.audioSession = [AVAudioSession sharedInstance];
}

- (void)configureAudioPlayer {
	NSURL * backgroundMusicURL = [NSURL fileURLWithPath:self.song.path];
	NSError * error;
	self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    
	self.backgroundMusicPlayer.delegate = self;
	self.backgroundMusicPlayer.numberOfLoops = 0;
	//	BOOL loadSuccess =
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

- (void)flashGestureLabel {
	[self flashGestureLabelWithDuration:.4];
}

-(BOOL)audioIsPlaying {
    return self.backgroundMusicPlayer.isPlaying;
}

-(void)flashGestureLabelWithDuration:(float)duration {
	[self.gestureLabel setAlpha:0];
	[UIView animateWithDuration:.4 animations:^{
        [self.gestureLabel setAlpha:1];
    }];
    
	[UIView animateWithDuration:duration delay:.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.gestureLabel setAlpha:0];
    } completion:nil];
}

-(IBAction)playPauseAudio:(id)sender {
	if (self.backgroundMusicPlaying) {
		[self stopAudio:nil];
		[self.gestureLabel setText:@"Pause"];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
	}
	else
	{
		[self playAudio:nil];
		[self.gestureLabel setText:@"Play"];
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
	}
    
	[self flashGestureLabel];
}

-(void)stopAudio:(id)sender {
	[self setBackgroundMusicPlaying:NO];
	[self.backgroundMusicPlayer stop];
}

- (IBAction)nextSong:(id)sender {
	NSUInteger currIndex = [self.songs indexOfObject:self.song];
	self.song.isLastPlayed = [NSNumber numberWithBool:FALSE];
    
	if (currIndex == self.songs.count - 1) {
		self.gestureLabel.text = @"No more songs";
		[self flashGestureLabel];
		return;
	}
    
	[self stopAudio:nil];
	self.song = [self.songs objectAtIndex:(currIndex + 1) % self.songs.count];
    if (shouldSkipCrossTrack) {
        self.song.currentPosition = [NSNumber numberWithDouble:skipToTime];
    }
    
	[self configureAudioPlayer];
	[self.backgroundMusicPlayer setCurrentTime:self.song.currentPosition.doubleValue];
	[self tryPlayMusic];
}

// TODO: add left panel setting for skipping/seeking across tracks


- (IBAction)previousSong:(UIButton *)sender {
	NSUInteger currIndex = [self.songs indexOfObject:self.song];
	if (currIndex == 0) {
		self.gestureLabel.text = @"No previous songs";
		[self flashGestureLabel];
		return;
	}
    
	[self stopAudio:nil];
	self.song.isLastPlayed = [NSNumber numberWithBool:FALSE];
	self.song = [self.songs objectAtIndex:(currIndex - 1) % self.songs.count];
    if (shouldSkipCrossTrack) {
        self.song.currentPosition = [NSNumber numberWithDouble:self.song.duration.doubleValue + skipToTime];
    }
    
	[self configureAudioPlayer];
	[self.backgroundMusicPlayer setCurrentTime:self.song.currentPosition.doubleValue];
	[self tryPlayMusic];
}

-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player successfully:(BOOL)flag
{
	[self nextSong:nil];
}


-(void)audioPlayerDecodeErrorDidOccur: (AVAudioPlayer *)player error:(NSError *)error
{
}

-(BOOL)shouldAutorotate {
	return YES;
}

@end
