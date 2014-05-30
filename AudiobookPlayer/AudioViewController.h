//
//  AudioViewController.h
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface AudioViewController : UIViewController <AVAudioPlayerDelegate>

@property (strong, nonatomic) NSString * audioPath;

- (IBAction)playAudio:(id)sender;
- (IBAction)playPauseAudio:(id)sender;
- (IBAction)stopAudio:(id)sender;
@end
