//
//  NSString+Addons.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 6/6/14.
//
//

#import "NSString+Addons.h"

@implementation NSString (Addons)

-(BOOL)contains:(NSString *)string {
	NSRange range = [self rangeOfString:string];
	return range.location != NSNotFound;
}


@end
