//
//  Song+Create.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 6/5/14.
//
//

#import "AudiobookPlayerAppDelegate.h"
#import "Song+Create.h"

@implementation Song (Create)

+(Song *)songWithSongTitle:(NSString *)title {
	Song * song = nil;
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	NSManagedObjectContext * context = delegate.managedObjectContext;
    
	NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
	request.predicate = [NSPredicate predicateWithFormat:@"title = %@", title];
    
	NSError * error;
	NSArray * matches = [context executeFetchRequest:request error:&error];
    
	if (error || !matches || ([matches count] > 1)) {
		// handle error
		NSLog(@"Error: %@", error);
	}
	else if (![matches count]) {
		song = [NSEntityDescription insertNewObjectForEntityForName:@"Song"
                                             inManagedObjectContext:context];
		song.title = title;
	}
	else {
		song = [matches firstObject];
	}
    
	return song;
}

+(Song *)songWithSongFullPath:(NSString *)pathName {
	Song * song = nil;
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	NSManagedObjectContext * context = delegate.managedObjectContext;
    
	NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
	request.predicate = [NSPredicate predicateWithFormat:@"path = %@", pathName];
    
	NSError * error;
	NSArray * matches = [context executeFetchRequest:request error:&error];
    
	if (error || !matches || ([matches count] > 1)) {
		// handle error
		NSLog(@"Error: %@", error);
	}
	else if (![matches count]) {
		song = [NSEntityDescription insertNewObjectForEntityForName:@"Song"
                                             inManagedObjectContext:context];
	}
	else {
		song = [matches firstObject];
	}
    
	return song;
}

+(Song *)songWithSongInfo:(NSDictionary *)songDictionary {
	Song * song = nil;
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	NSManagedObjectContext * context = delegate.managedObjectContext;
    
	NSString * unique = [songDictionary valueForKeyPath:SONG_TITLE];
    
	NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
	request.predicate = [NSPredicate predicateWithFormat:@"title = %@", unique];
    
	NSError * error;
	NSArray * matches = [context executeFetchRequest:request error:&error];
    
	if (error || !matches || ([matches count] > 1)) {
		// handle error
		NSLog(@"Error: %@", error);
	}
	else if (![matches count]) {
		song = [NSEntityDescription insertNewObjectForEntityForName:@"Song"
                                             inManagedObjectContext:context];
		song.title = [songDictionary valueForKeyPath:SONG_TITLE];
		song.duration = [songDictionary valueForKeyPath:SONG_DURATION];
		song.path = [songDictionary valueForKeyPath:SONG_PATH];
	}
	else {
		song = [matches firstObject];
	}
    
	return song;
}

@end
