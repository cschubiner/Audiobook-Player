//
//  Song+Create.h
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 6/5/14.
//
//

#import "Song.h"

#define SONG_TITLE @"song_title"
#define SONG_DURATION @"SONG_DURATION"
#define SONG_PATH @"SONG_PATH"

@interface Song (Create)



+ (Song *)songWithSongInfo:(NSDictionary *)songDictionary;
+ (Song *)songWithSongTitle:(NSString *)title;
+ (Song *)songWithSongFullPath:(NSString *)pathName;

@end
