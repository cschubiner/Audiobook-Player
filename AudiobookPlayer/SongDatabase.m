//
//  FlickrDatabase.m
//  Photomania
//
//  Created by CS193p Instructor on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "SongDatabase.h"

@interface SongDatabase ()
@property (nonatomic, readwrite, strong) NSManagedObjectContext * managedObjectContext;
@end

@implementation SongDatabase

+ (SongDatabase *)sharedDefaultSongDatabase
{
	return [self sharedSongDatabaseWithName:DATABASE_NAME];
}

+ (SongDatabase *)sharedSongDatabaseWithName:(NSString *)name
{
	static NSMutableDictionary * databases = nil;
	if (!databases) databases = [[NSMutableDictionary alloc] init];
    
	SongDatabase * database = nil;
    
	if ([name length]) {
		database = databases[name];
		if (!database) {
			database = [[self alloc] initWithName:name];
			databases[name] = database;
		}
	}
    
	return database;
}

- (void)saveDocumentToURL:(UIManagedDocument *)document url:(NSURL *)url
{
                DebugLog(@"g");
	[document saveToURL:url
       forSaveOperation:UIDocumentSaveForCreating
      completionHandler:^(BOOL success) {
                DebugLog(@"e");
          if (success) {
              self.managedObjectContext = document.managedObjectContext;
          }
      }];
                DebugLog(@"f");
}

- (instancetype)initWithName:(NSString *)name
{
                DebugLog(@"h");
	self = [super init];
	if (self) {
		if ([name length]) {
			NSURL * url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                  inDomains:NSUserDomainMask] firstObject];
			url = [url URLByAppendingPathComponent:name];
			UIManagedDocument * document = [[UIManagedDocument alloc] initWithFileURL:url];
                DebugLog(@"c");
			if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
				[document openWithCompletionHandler:^(BOOL success) {
                    if (success) {
                        self.managedObjectContext = document.managedObjectContext;
                    }
                    else {
                        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                        [self saveDocumentToURL:document url:url];
                DebugLog(@"b");
                    }
                }];
			}
			else {
				[self saveDocumentToURL:document url:url];
                DebugLog(@"a");
			}
		}
		else {
			self = nil;
		}
	}
                DebugLog(@"d");
    
	return self;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	_managedObjectContext = managedObjectContext;
	[[NSNotificationCenter defaultCenter] postNotificationName:FlickrDatabaseAvailable
                                                        object:self];
}


@end
