//
//  Song.h
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 6/6/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Song : NSManagedObject

@property (nonatomic, retain) NSNumber * currentPosition;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * isLastPlayed;

@end
