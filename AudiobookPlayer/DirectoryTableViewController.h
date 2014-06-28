//
//  DirectoryTableViewController.h
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import <UIKit/UIKit.h>
#import "AudioToolbar.h"

@interface DirectoryTableViewController : UITableViewController

@property (nonatomic, strong) NSString * directoryPath;

-(void)refreshTableView;

@property (nonatomic, strong) NSArray* files;

@end
