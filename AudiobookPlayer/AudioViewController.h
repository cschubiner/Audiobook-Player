//
//  AudioViewController.h
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import "CPSlider.h"
#import "Song.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface AudioViewController : UIViewController <AVAudioPlayerDelegate, CPSliderDelegate>

@property (strong, nonatomic) NSMutableArray * songs;

- (IBAction)playAudio:(id)sender;
- (IBAction)playPauseAudio:(id)sender;
- (IBAction)stopAudio:(id)sender;
- (IBAction)previousSong:(UIButton *)sender;
- (IBAction)nextSong:(id)sender;

- (void)skipWithDuration:(CGFloat)skipDuration;

-(BOOL)audioIsPlaying;

@property (nonatomic) NSUInteger firstSongIndex;

-(Song*)getSong;
-(void)recordCurrNoSave;
@end
