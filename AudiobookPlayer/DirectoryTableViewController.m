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

@interface DirectoryTableViewController ()
@property (nonatomic, strong) NSArray* files;

@end

@implementation DirectoryTableViewController



- (IBAction)didPullDownRefreshControl:(id)sender {
	[self refreshTableView];
}

-(void)reloadFiles {
	self.files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directoryPath error:NULL];
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
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FolderCellTableViewCell" forIndexPath:indexPath];
    
	NSString * pathName = [self.files objectAtIndex:indexPath.row];
	NSString * fullPath = [self.directoryPath stringByAppendingPathComponent:pathName];
	BOOL isDirectory = [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory];
    
	[[cell textLabel]setText:pathName];
    
	return cell;
}

+(BOOL)isDirectory:(NSString*)path {
	BOOL isDirectory;
	isDirectory = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
	NSURL * item = [NSURL URLWithString:path];
	NSNumber * isDir;
	BOOL gel = [item getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
	if (gel) {
		if ([isDir boolValue]) {
			NSLog(@"%@ is a directory", item);
		}
		else {
			NSLog(@"%@ is a file", item);
		}
	}
    
	return gel;
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
		UIStoryboard * storyboard = [((AudiobookPlayerAppDelegate*)[[UIApplication sharedApplication]delegate])storyboard];
		AudioViewController * next = [storyboard instantiateViewControllerWithIdentifier:@"audioView"];
		[next setAudioPath:fullPath];
		[self.navigationController pushViewController:next animated:YES];
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