//
//  CenterPanelTableViewController.m
//
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import "CenterPanelTableViewController.h"

@interface CenterPanelTableViewController ()

@end

@implementation CenterPanelTableViewController

+ (NSString *)documentsDirectory
{
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return ([paths count] > 0) ?[paths objectAtIndex:0] : nil;
}

-(void)viewDidLoad {
	[self setDirectoryPath:[CenterPanelTableViewController documentsDirectory]];
	[super viewDidLoad];
}

@end
