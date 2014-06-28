//
//  AudioToolbar.h
//  AudiobookPlayer
//
//  Created by Clayton Schubiner on 6/28/14.
//
//

#import <Foundation/Foundation.h>

@interface AudioToolbar : NSObject

-(AudioToolbar *)initWithViewController:(UIViewController *)vc andTransparency:(CGFloat)transparency;
-(void)correctPlayPause;

@end
