//
//  CenterPanelTableViewController.m
//
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import "AudiobookPlayerAppDelegate.h"
#import "CenterPanelTableViewController.h"
#import "DirectoryTableViewController.h"
#import "ProgressCellTableViewCell.h"
#import "SongDatabase.h"

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
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	[delegate setCenterPanelController:self];
	[super viewDidLoad];
	id observer = NULL;
	observer = [[NSNotificationCenter defaultCenter] addObserverForName:FlickrDatabaseAvailable
                                                                 object:[SongDatabase sharedDefaultSongDatabase]
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification * note) {
                                                                 [self refreshTableView];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                             }];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return true;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.files.count > 0) {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
		return;
	}
    
	UIAlertView * filenameAlert = [[UIAlertView alloc] initWithTitle:@"Welcome!" message:@"Download new files with the Downloader (swipe right). Or select \"Audiobook Player\" when opening audio files in other apps." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[filenameAlert show];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.files.count > 0)
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
	ProgressCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FolderCellTableViewCell" forIndexPath:indexPath];
	//	FolderCellTableViewCell * cell = [[FolderCellTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FolderCellTableViewCell"];
    
    
	cell.textLabel.text = @"Getting started";
	[cell setSong:nil];
    
	return cell;
}

@end
