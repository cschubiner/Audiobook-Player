//
//  DirectoryTableViewController.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import "AudioViewController.h"
#import "AudiobookPlayerAppDelegate.h"
#import "DirectoryTableViewController.h"
#import "FolderCellTableViewCell.h"
#import "Song+Create.h"
#import "Song.h"
#import "SongDatabase.h"

@interface DirectoryTableViewController ()
@property (nonatomic, strong) NSArray* files;

@end

@implementation DirectoryTableViewController



- (IBAction)didPullDownRefreshControl:(id)sender {
	[self refreshTableView];
}

+(NSString*)pathNameToSongTitle:(NSString*)pathName {
	return [[pathName lastPathComponent]stringByDeletingPathExtension];
}

-(NSNumber *)getDurationOfFilePath:(NSString*)pathName {
	NSString * fullPath = [self.directoryPath stringByAppendingPathComponent:pathName];
	return [NSNumber numberWithFloat:[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:fullPath] error:nil].duration];
}

-(void)reloadFiles {
	self.files = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directoryPath error:NULL]];
	int databaseIndex = -1;
	for (NSString * pathName in self.files) {
		if ([pathName isEqualToString:DATABASE_NAME]) {
			databaseIndex = [self.files indexOfObject:pathName];
			continue;
		}
        
		if (![DirectoryTableViewController isDirectory:pathName]) {
			NSString * fullPath = [self.directoryPath stringByAppendingPathComponent:pathName];
            
			NSDictionary * dict = @{ SONG_TITLE : [DirectoryTableViewController pathNameToSongTitle:pathName], SONG_DURATION : [self getDurationOfFilePath:pathName],
                                     SONG_PATH : fullPath};
			Song * song = [Song songWithSongInfo:dict];
			if (!song.path)
				song.path = [dict valueForKeyPath:SONG_PATH];
            
		}
	}
    
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	[delegate.managedObjectContext save:nil];
    
	if (databaseIndex >= 0)
		[(NSMutableArray*)self.files removeObjectAtIndex : databaseIndex];
}

-(void)refreshTableView {
	[self reloadFiles];
	[self.tableView reloadData];
	[self.refreshControl endRefreshing];
}

- (void)viewDidLoad
{
	[self.tableView registerClass:[FolderCellTableViewCell class] forCellReuseIdentifier:@"FolderCellTableViewCell"];
	[super viewDidLoad];
    
	[self reloadFiles];
    
	id observer = [[NSNotificationCenter defaultCenter] addObserverForName:FlickrDatabaseAvailable
                                                                    object:[SongDatabase sharedDefaultSongDatabase]
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification * note) {
                                                                    [self refreshTableView];
                                                                    [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                }];
    
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//	FolderCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FolderCellTableViewCell" forIndexPath:indexPath];
    FolderCellTableViewCell * cell = [[FolderCellTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FolderCellTableViewCell"];
    
	NSString * pathName = [self.files objectAtIndex:indexPath.row];
	NSString * fullPath = [self.directoryPath stringByAppendingPathComponent:pathName];
	BOOL isDirectory = [DirectoryTableViewController isDirectory:pathName];
    
	UIFont * italicFont = [UIFont fontWithName:@"HelveticaNeue-UltraLightItalic" size:15];
	UIFont * font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    
	if (isDirectory) {
		font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.5];
	}
    
	NSString * title = [DirectoryTableViewController pathNameToSongTitle:pathName];
	Song * song;
	if (!isDirectory)
		song = [Song songWithSongTitle:title];
    
	NSNumber * duration = song.duration;
    
    
	NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:title];
	[string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
    
	NSString * durString = @"Folder";
	if (!isDirectory) {
		if (song) {
			durString = [NSString stringWithFormat:@"%d:%02d", ((int)duration.floatValue / 60), ((int)duration.floatValue % 60)];
			[cell setSong:song];
			[cell updateProgress];
		}
		else durString = @"";
	}
    
	NSMutableAttributedString * durAttributedString = [[NSMutableAttributedString alloc]initWithString:durString];
	[durAttributedString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(0, durString.length)];
	cell.detailTextLabel.attributedText = durAttributedString;
    
	cell.textLabel.attributedText = string;
    
    
	return cell;
}

+(BOOL)isDirectory:(NSString*)path {
	BOOL isDirectory;
	isDirectory = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
	NSURL * item = [NSURL URLWithString:path];
	NSNumber * isDir;
	BOOL ret = [item getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
	if (ret) {
		//		if ([isDir boolValue])
		//			NSLog(@"%@ is a directory", item);
		//		else
		//			NSLog(@"%@ is a file", item);
	}
    
	return ret;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString * pathName = [self.files objectAtIndex:indexPath.row];
	NSString * fullPath = [self.directoryPath stringByAppendingPathComponent:pathName];
    
	if ([DirectoryTableViewController isDirectory:fullPath]) {
		DirectoryTableViewController * next = [[DirectoryTableViewController alloc]init];
		[next setDirectoryPath:fullPath];
		[self.navigationController pushViewController:next animated:YES];
	}
	else {
		AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
		Song * song = [Song songWithSongFullPath:fullPath];
        
		if ([fullPath isEqualToString:delegate.currentAudioViewController.song.path]) {
			[self.navigationController pushViewController:delegate.currentAudioViewController animated:YES];
		}
		else {
			UIStoryboard * storyboard = [((AudiobookPlayerAppDelegate*)[[UIApplication sharedApplication]delegate])storyboard];
			AudioViewController * next = [storyboard instantiateViewControllerWithIdentifier:@"audioView"];
			[next setSong:song];
			[self.navigationController pushViewController:next animated:YES];
		}
	}
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end