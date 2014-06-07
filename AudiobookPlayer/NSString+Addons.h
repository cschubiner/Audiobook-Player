//
//  NSString+Addons.h
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 6/6/14.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Addons)
-(BOOL)isBlank;
-(BOOL)contains:(NSString *)string;
-(NSArray *)splitOnChar:(char)ch;
-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to;
-(NSString *)stringByStrippingWhitespace;

@end
