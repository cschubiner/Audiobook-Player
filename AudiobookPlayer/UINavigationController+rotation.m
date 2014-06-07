//
//  UINavigationController+rotation.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 6/6/14.
//
//

#import "UINavigationController+rotation.h"

@implementation UINavigationController (rotation)

- (BOOL)shouldAutorotate
{
	return [[self topViewController] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return [[self topViewController] supportedInterfaceOrientations];
}

@end
