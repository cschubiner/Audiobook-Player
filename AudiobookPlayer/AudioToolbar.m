//
//  AudioToolbar.m
//  AudiobookPlayer
//
//  Created by Clayton Schubiner on 6/28/14.
//
//

#import "AudioToolbar.h"
#import "AudioViewController.h"
#import "AudiobookPlayerAppDelegate.h"

@interface AudioToolbar ()
@property (nonatomic) UIViewController * vc;
@property CGFloat transparency;
@end

@implementation AudioToolbar

-(AudioToolbar *)initWithViewController:(UIViewController *)vc andTransparency:(CGFloat)transparency {
	id ret = [super init];
	if (ret) {
		self.transparency = transparency;
		[self setupToolbar:vc];
	}
    
	return ret;
}

+(UIImage *)imageWithColor:(UIColor *)color
{
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
    
	UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return image;
}

-(void)setupToolbar:(UIViewController *)vc {
	self.vc = vc;
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	vc.toolbarItems = [NSArray arrayWithObjects:
	                   [[UIBarButtonItem alloc] initWithTitle:@"Prev." style:UIBarButtonItemStylePlain target:self action:@selector(prevTrack:)],
	                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
	                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                     target:self
                                                                     action:@selector(skipBackwards:)],
	                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
	                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:[delegate.currentAudioViewController audioIsPlaying] ? UIBarButtonSystemItemPause:UIBarButtonSystemItemPlay
                                                                     target:self
                                                                     action:@selector(playPauseAudio:)],
	                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
	                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                     target:self
                                                                     action:@selector(skipForwards:)],
	                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
	                   [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextTrack:)],
	                   nil];
	vc.navigationController.toolbarHidden = NO;
    
	UIImage * transparentImage = [AudioToolbar imageWithColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:self.transparency]];
	[vc.navigationController.toolbar setBackgroundImage:transparentImage
                                     forToolbarPosition:UIBarPositionAny
                                             barMetrics:UIBarMetricsDefault];
	[vc.navigationController.toolbar setShadowImage:transparentImage
                                 forToolbarPosition:UIToolbarPositionAny];
}

-(void)playPauseAudio:(id)sender {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	[delegate.currentAudioViewController playPauseAudio:nil];
    
	[self correctPlayPause];
}

-(void)correctPlayPause {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	NSMutableArray * items = [[NSMutableArray alloc] initWithArray:self.vc.toolbarItems];
	items[4] = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:[delegate.currentAudioViewController audioIsPlaying] ? UIBarButtonSystemItemPause:UIBarButtonSystemItemPlay target:self action:@selector(playPauseAudio:)];
	self.vc.toolbarItems = items;
}

-(void)nextTrack:(id)sender {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	[delegate.currentAudioViewController nextSong:nil];
    if ([delegate.currentAudioViewController audioIsPlaying])
        [self correctPlayPause];
}

-(void)prevTrack:(id)sender {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	[delegate.currentAudioViewController previousSong:nil];
    if ([delegate.currentAudioViewController audioIsPlaying])
        [self correctPlayPause];
}

-(void)skipForwards:(id)sender {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	[delegate.currentAudioViewController skipWithDuration:10];
}

-(void)skipBackwards:(id)sender {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	[delegate.currentAudioViewController skipWithDuration:-10];
}
@end
