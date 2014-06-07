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

#define PI 3.1415926535897932384626

@end

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
}

- (void)sliderDidEndSliding:(NSNotification *)notification {
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
	self.song = [self.songs objectAtIndex:0];
	[self configureAudioSession];
	[self configureAudioPlayer];
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	if (self != delegate.currentAudioViewController) {
		delegate.currentAudioViewController.getSong.isLastPlayed = [NSNumber numberWithBool:FALSE];
		[delegate.currentAudioViewController recordCurrentPosition];
		[delegate.managedObjectContext save:nil];
		[[delegate.currentAudioViewController backgroundMusicPlayer]stop];
		[delegate setCurrentAudioViewController:self];
	}
    
	[self.backgroundMusicPlayer setCurrentTime:self.song.currentPosition.doubleValue];
	[self setupSlider];
	[self tryPlayMusic];
}


-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	[self recordCurrentPosition];
	[delegate.managedObjectContext save:nil];
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

- (IBAction)didPan:(UIPanGestureRecognizer *)sender {
	static CGPoint startingPoint;
	static CGPoint endPoint;
    
	if (sender.state == UIGestureRecognizerStateBegan) {
		startingPoint  = [sender locationInView:sender.view];
	}
	else if (sender.state == UIGestureRecognizerStateEnded) {
		endPoint = [sender locationInView:sender.view];
		CGFloat angle = atan2(startingPoint.y - endPoint.y, endPoint.x - startingPoint.x);
        
		const CGFloat maxSecondsToSkip = 30;
		CGFloat skipDuration = -(fabsf(angle) - PI / 2) * maxSecondsToSkip * 30.0 / 7.0 / PI / 2;
		[self.gestureLabel setText:[NSString stringWithFormat:@"%@ %d secs", skipDuration >= 0 ? @"Jumping" :@"Reversing", abs((int)skipDuration)]];
		[self flashGestureLabel];
		self.backgroundMusicPlayer.currentTime += skipDuration;
		self.seekSlider.value += skipDuration;
		[self updateCurrentTimeLabel];
        
		[self recordCurrentPosition];
	}
    
	//	switch (sender.state) {
	//        case UIGestureRecognizerStateBegan:
	//            CGFloat angle = atan2f(velocity.y, velocity.x);
	//            NSLog(@"angle %f", angle);
	//
	//            break;
	//        case UIGestureRecognizerStateEnded:
	//            CGPoint velocity = [sender velocityInView:[sender.view superview]];
	//            // If needed: CGFloat slope = velocity.y / velocity.x;
	//
	//            break;
	//	}
}


- (IBAction)didTapView:(id)sender {
	[self playPauseAudio:nil];
	[self recordCurrentPosition];
}

-(void)recordCurrentPosition {
	//	[((AudiobookPlayerAppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext performBlock :^{
	self.song.currentPosition = [NSNumber numberWithDouble:self.backgroundMusicPlayer.currentTime];
	//    }];
}

- (void)updateTime:(NSTimer *)timer {
	self.seekSlider.value = self.backgroundMusicPlayer.currentTime;
    [self updateCurrentTimeLabel];
	[self recordCurrentPosition];
}

- (void)tryPlayMusic {
	if (self.backgroundMusicPlaying || [self.audioSession isOtherAudioPlaying]) {
		return;
	}
    
	[self.backgroundMusicPlayer play];
	self.backgroundMusicPlaying = YES;
    
	self.song.isLastPlayed = [NSNumber numberWithBool:TRUE];
	self.durationLabel.text = [NSString stringWithFormat:@"%d:%02d", ((int)self.song.duration.floatValue / 60), ((int)self.song.duration.floatValue % 60)];

    
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
	// Create audio player with background music
	NSURL * backgroundMusicURL = [NSURL fileURLWithPath:self.song.path];
	self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:nil];
	self.backgroundMusicPlayer.delegate = self; // We need this so we can restart after interruptions
	self.backgroundMusicPlayer.numberOfLoops = 0;
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
	}
	else
	{
		[self playAudio:nil];
		[self.gestureLabel setText:@"Play"];
	}
    
	[self flashGestureLabel];
}

-(void)stopAudio:(id)sender {
	[self setBackgroundMusicPlaying:NO];
	[self.backgroundMusicPlayer stop];
}

- (IBAction)nextSong:(id)sender {
	[self stopAudio:nil];
	NSUInteger currIndex = [self.songs indexOfObject:self.song];
	self.song.isLastPlayed = [NSNumber numberWithBool:FALSE];
	self.song = [self.songs objectAtIndex:(currIndex + 1) % self.songs.count];
	[self configureAudioPlayer];
	[self tryPlayMusic];
}

-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player successfully:(BOOL)flag
{
	[self nextSong:nil];
}

-(void)audioPlayerDecodeErrorDidOccur: (AVAudioPlayer *)player error:(NSError *)error
{
}

@end
