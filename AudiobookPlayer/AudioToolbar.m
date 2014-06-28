//
//  AudioToolbar.m
//  AudiobookPlayer
//
//  Created by Clayton Schubiner on 6/28/14.
//
//

#import "AudioToolbar.h"
#import "AudiobookPlayerAppDelegate.h"
#import "AudioViewController.h"

@interface AudioToolbar ()
@property (nonatomic) UIViewController * vc;
@end

@implementation AudioToolbar

-(AudioToolbar *)initWithViewController:(UIViewController *)vc {
    id ret = [super init];
    if (ret) {
        [self setupToolbar:vc];
    }
    return ret;
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
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:[delegate.currentAudioViewController audioIsPlaying] ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay
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
}

-(void)playPauseAudio:(id)sender {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
    [delegate.currentAudioViewController playPauseAudio:nil];
    
    [self correctPlayPause];
}

-(void)correctPlayPause {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
    NSMutableArray * items = [[NSMutableArray alloc] initWithArray:self.vc.toolbarItems];
    items[4] = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:[delegate.currentAudioViewController audioIsPlaying] ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay target:self action:@selector(playPauseAudio:)];
    self.vc.toolbarItems = items;
}

-(void)nextTrack:(id)sender {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
    [delegate.currentAudioViewController nextSong:nil];
}

-(void)prevTrack:(id)sender {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
    [delegate.currentAudioViewController previousSong:nil];
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
