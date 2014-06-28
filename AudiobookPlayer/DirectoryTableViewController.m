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
#import "ProgressCellTableViewCell.h"
#import "Song+Create.h"
#import "Song.h"
#import "SongDatabase.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed : ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green : ((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue : ((float)(rgbValue & 0xFF)) / 255.0 alpha : 1.0]


@interface DirectoryTableViewController ()

@end

@implementation DirectoryTableViewController

-(void)playPauseAudio:(id)sender {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
    [delegate.currentAudioViewController playPauseAudio:nil];
    
    
    NSMutableArray * items = [[NSMutableArray alloc] initWithArray:self.toolbarItems];
    items[4] = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:[delegate.currentAudioViewController audioIsPlaying] ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay target:self action:@selector(playPauseAudio:)];
    self.toolbarItems = items;
}

-(void)nextTrack:(id)sender {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
    [delegate.currentAudioViewController nextSong:nil];
}

-(void)prevTrack:(id)sender {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
    [delegate.currentAudioViewController previousSong:nil];
}

-(void)skipForwards:(id)sender {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
    [delegate.currentAudioViewController skipWithDuration:10];
}

-(void)skipBackwards:(id)sender {
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
    [delegate.currentAudioViewController skipWithDuration:-10];
}

- (IBAction)didPullDownRefreshControl:(id)sender {
	[self refreshTableView];
}

+(NSString*)pathNameToSongTitle:(NSString*)pathName {
	return [[pathName lastPathComponent]stringByDeletingPathExtension];
}

-(NSNumber *)getDurationOfFilePath:(NSString*)pathName {
	NSString * fullPath = [self.directoryPath stringByAppendingPathComponent:pathName];
    
	NSURL * afUrl = [NSURL fileURLWithPath:fullPath];
	AudioFileID fileID;
	OSStatus result = AudioFileOpenURL((__bridge CFURLRef)afUrl, kAudioFileReadPermission, 0, &fileID);
	Float64 outDataSize = 0;
	UInt32 thePropSize = sizeof(Float64);
	result = AudioFileGetProperty(fileID, kAudioFilePropertyEstimatedDuration, &thePropSize, &outDataSize);
	AudioFileClose(fileID);
	return [NSNumber numberWithInt:result];
}

-(void)reloadFiles {
	self.files = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directoryPath error:NULL]];
	NSInteger databaseIndex = -1;
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
			//			if (!song.path)
			song.path = [dict valueForKeyPath:SONG_PATH];
            
		}
	}
    
	[((AudiobookPlayerAppDelegate*)[UIApplication sharedApplication].delegate)saveContext];
    
	if (databaseIndex >= 0)
		[(NSMutableArray*)self.files removeObjectAtIndex : databaseIndex];
}

bool isLoading = false;

-(void)refreshTableView {
	isLoading = true;
	[self.refreshControl beginRefreshing];
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	if (delegate.managedObjectContext) {
		[delegate.managedObjectContext performBlock:^{
            [self reloadFiles];
            dispatch_async(dispatch_get_main_queue(), ^{
                isLoading = false;
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
            });
        }];
	}
}

-(void)updateColorScheme {
	NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSInteger colorScheme = [standardUserDefaults integerForKey:@"colorScheme"];
	if (colorScheme == 0) {
		[self.tableView setBackgroundColor:[UIColor lightGrayColor]];
		[self.tableView setSeparatorColor:[UIColor lightGrayColor]];
		[self.navigationController.navigationBar setBarTintColor:[UIColor darkGrayColor]];
		[self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
		[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	}
	else {
		[self.tableView setBackgroundColor:[UIColor whiteColor]];
		[self.tableView setSeparatorColor:[UIColor whiteColor]];
		[self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
		[self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
		[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
	}
}

- (void)viewDidLoad
{
	[self.tableView registerClass:[ProgressCellTableViewCell class] forCellReuseIdentifier:@"FolderCellTableViewCell"];
 
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
    self.toolbarItems = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc] initWithTitle:@"Prev." style:UIBarButtonItemStylePlain target:self action:@selector(prevTrack:)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                         target:self
                                                                         action:@selector(skipBackwards:)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:[delegate.currentAudioViewController audioIsPlaying] ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay
                                                                         target:self
                                                                         action:@selector(playPauseAudio:)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                         target:self
                                                                         action:@selector(skipForwards:)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextTrack:)],
                           nil];
    
    self.navigationController.toolbarHidden = NO;
    
	[super viewDidLoad];
	[self updateColorScheme];
	[self refreshTableView];
    
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return max(1, self.files.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ProgressCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FolderCellTableViewCell" forIndexPath:indexPath];
	//	FolderCellTableViewCell * cell = [[FolderCellTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FolderCellTableViewCell"];
    
    
	if (self.files.count == 0) {
		cell.textLabel.text = isLoading ? @"Loading..." : @"Empty folder";
		[cell setSong:nil];
		return cell;
	}
    
	NSString * pathName = [self.files objectAtIndex:indexPath.row];
	NSString * fullPath = [self.directoryPath stringByAppendingPathComponent:pathName];
	BOOL isDirectory = [DirectoryTableViewController isDirectory:fullPath];
    
	UIFont * italicFont = [UIFont fontWithName:@"HelveticaNeue-UltraLightItalic" size:15];
	UIFont * font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    
	if (isDirectory) {
		font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.5];
		[cell setIsDirectory:TRUE];
	}
    
	NSString * title = [DirectoryTableViewController pathNameToSongTitle:pathName];
	Song * song;
	if (!isDirectory)
		song = [Song songWithSongTitle:title];
    
	NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:title];
	[string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
    
	NSString * durString = @"Folder";
	if (!isDirectory) {
		if (song) {
			durString = [NSString stringWithFormat:@"%d:%02d", ((int)song.duration.floatValue / 60), ((int)song.duration.floatValue % 60)];
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
	NSURL * item = [NSURL fileURLWithPath:path];
	NSNumber * isDir;
	BOOL ret = [item getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
	if (ret) {
		//		if ([isDir boolValue])
		//			DebugLog(@"%@ is a directory", item);
		//		else
		//			DebugLog(@"%@ is a file", item);
	}
    
	return ([path rangeOfString:@".m"].location == NSNotFound) && (ret || isDirectory);
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return self.files.count != 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.files.count == 0) return;
    
	NSString * pathName = [self.files objectAtIndex:indexPath.row];
	NSString * fullPath = [self.directoryPath stringByAppendingPathComponent:pathName];
    
	if ([DirectoryTableViewController isDirectory:fullPath]) {
		DirectoryTableViewController * next = [[DirectoryTableViewController alloc]init];
		[next setDirectoryPath:fullPath];
		[next setTitle:pathName];
		[self.navigationController pushViewController:next animated:YES];
	}
	else {
		AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
        
		if ([fullPath isEqualToString:((Song*)delegate.currentAudioViewController.getSong).path]) {
			[self.navigationController pushViewController:delegate.currentAudioViewController animated:YES];
		}
		else {
			UIStoryboard * storyboard = [((AudiobookPlayerAppDelegate*)[[UIApplication sharedApplication]delegate])storyboard];
			AudioViewController * next = [storyboard instantiateViewControllerWithIdentifier:@"audioView"];
			NSMutableArray * songs = [[NSMutableArray alloc]init];
			Song * thisSong;
			for (NSInteger i = 0; i < self.files.count; i++) {
				NSString * songPath = [self.files objectAtIndex:i];
				if (![DirectoryTableViewController isDirectory:[self.directoryPath stringByAppendingPathComponent:songPath]]) {
					Song * song = [Song songWithSongTitle:[DirectoryTableViewController pathNameToSongTitle:songPath]];
					if (i == indexPath.row)
						thisSong = song;
                    
					[songs addObject:song];
				}
			}
            
			[next setFirstSongIndex:[songs indexOfObject:thisSong]];
			[next setSongs:songs];
            
			[self.navigationController pushViewController:next animated:YES];
		}
	}
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

-(NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.files.count == 0) return false;
    
	NSString * pathName = [self.files objectAtIndex:indexPath.row];
	NSString * fullPath = [self.directoryPath stringByAppendingPathComponent:pathName];
    
	return ![DirectoryTableViewController isDirectory:fullPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.files.count == 0) return;
    
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source
		NSString * pathName = [self.files objectAtIndex:indexPath.row];
		NSString * fullPath = [self.directoryPath stringByAppendingPathComponent:pathName];
        
		NSFileManager * fileManager = [NSFileManager defaultManager];
		NSError * error;
		[fileManager removeItemAtPath:fullPath error:&error];
		if (!error) {
			self.files = [NSMutableArray arrayWithArray:self.files];
			[((NSMutableArray*)self.files)removeObjectAtIndex : indexPath.row];
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
	}
}

@end