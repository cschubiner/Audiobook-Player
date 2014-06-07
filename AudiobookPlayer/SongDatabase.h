//
//  FlickrDatabase.h
//  Photomania
//
//  Created by CS193p Instructor on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//
//  This class only works on the main queue!

#import <Foundation/Foundation.h>

#define FlickrDatabaseAvailable @"FlickrDatabaseAvailable"
#define DATABASE_NAME @"SongDatabase_SCHUBINER_ZZZZZZZZZZ"

@interface SongDatabase : NSObject

+ (SongDatabase *)sharedDefaultSongDatabase;
+ (SongDatabase *)sharedSongDatabaseWithName:(NSString *)name;

@property (nonatomic, readonly) NSManagedObjectContext * managedObjectContext;

@end
