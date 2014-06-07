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

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed : ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green : ((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue : ((float)(rgbValue & 0xFF)) / 255.0 alpha : 1.0]


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
	[self.refreshControl beginRefreshing];
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	[delegate.managedObjectContext performBlock:^{
        [self reloadFiles];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    }];
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
	UIViewController * c = [[UIViewController alloc]init];
	[self presentViewController:c animated:NO completion:nil];
	[self dismissViewControllerAnimated:NO completion:nil];
    
	[self.tableView registerClass:[FolderCellTableViewCell class] forCellReuseIdentifier:@"FolderCellTableViewCell"];
	[super viewDidLoad];
	[super willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];
	[self updateColorScheme];
	[self refreshTableView];
    
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
	FolderCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FolderCellTableViewCell" forIndexPath:indexPath];
	//	FolderCellTableViewCell * cell = [[FolderCellTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FolderCellTableViewCell"];
    
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
	NSURL * item = [NSURL URLWithString:path];
	NSNumber * isDir;
	BOOL ret = [item getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
	if (ret) {
		//		if ([isDir boolValue])
		//			NSLog(@"%@ is a directory", item);
		//		else
		//			NSLog(@"%@ is a file", item);
	}
    
	return ([path rangeOfString:@".m"].location == NSNotFound) && (ret || isDirectory);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
			for (int i = indexPath.row; i < self.files.count; i++) {
				NSString * songPath = [self.directoryPath stringByAppendingPathComponent:[self.files objectAtIndex:i]];
				if (![DirectoryTableViewController isDirectory:songPath])
					[songs addObject:[Song songWithSongFullPath:songPath]];
			}
            
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