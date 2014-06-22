//
//  LeftPanelViewController.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import "AudiobookPlayerAppDelegate.h"
#import "CenterPanelTableViewController.h"
#import "DownloadWebViewController.h"
#import "LeftPanelViewController.h"
#import "UITableViewCell+FlatUI.h"
#import <FlatUIKit/UIColor+FlatUI.h>
#import <Parse/Parse.h>

@implementation LeftPanelViewController

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) {
		// Custom initialization
	}
    
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	UILabel* lbNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 40)];
	lbNavTitle.textAlignment = NSTextAlignmentLeft;
    
	UIFont * font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.5];
	NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:@"      Settings"];
	[string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
	lbNavTitle.attributedText = string;
	lbNavTitle.textColor = [UIColor whiteColor];
	self.navigationItem.titleView = lbNavTitle;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	if ([PFUser currentUser] && [[PFUser currentUser] objectForKey:@"name"])
		return 5;
    
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell" forIndexPath:indexPath];
    
	[cell configureFlatCellWithColor:[UIColor greenSeaColor]
                       selectedColor:[UIColor cloudsColor] ];
	cell.cornerRadius = 5.0f; // optional
	cell.separatorHeight = 2.0f; // optional
    
	NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (indexPath.row == 0) {
		NSInteger isPanMode = [standardUserDefaults integerForKey:@"panMode"];
        
		if (isPanMode == 0) {
			cell.textLabel.text = @"Pan Mode";
		}
		else {
			cell.textLabel.text = @"Swipe Mode";
		}
	}
	else if (indexPath.row == 1) {
		NSInteger colorScheme = [standardUserDefaults integerForKey:@"colorScheme"];
        
		if (colorScheme == 1) {
			cell.textLabel.text = @"Light Colors";
		}
		else {
			cell.textLabel.text = @"Dark Colors";
		}
	}
	else if (indexPath.row == 2) {
		cell.textLabel.text = @"Downloader";
	}
	else if (indexPath.row == 3) {
		cell.textLabel.text = @"Sleep Timer";
	}
	else if (indexPath.row == 4) {
		cell.textLabel.text = [[PFUser currentUser] objectForKey:@"name"];
	}
    
	return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.row != 4;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (indexPath.row == 0) {
		NSInteger isPanMode = [standardUserDefaults integerForKey:@"panMode"];
		[standardUserDefaults setInteger:1 - isPanMode forKey:@"panMode"];
	}
	else if (indexPath.row == 1) {
		NSInteger colorScheme = [standardUserDefaults integerForKey:@"colorScheme"];
		[standardUserDefaults setInteger:1 - colorScheme forKey:@"colorScheme"];
//		UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Color scheme saved"
//                                                         message:@"The color scheme will enable next time you start the app."
//                                                        delegate:self
//                                               cancelButtonTitle:@"Dismiss"
//                                               otherButtonTitles:nil];
//		[alert show];
	}
	else if (indexPath.row == 2) {
		AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
		DownloadWebViewController * webViewController = delegate.downloadViewController;
		[self presentViewController:webViewController animated:YES completion:nil];
		return;
	}
	else if (indexPath.row == 3) {
		UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Sleep Timer"
                                                         message:@"How many minutes should Audiobook Player wait until pausing the audio?"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Set Timer", nil];
		alert.alertViewStyle = UIAlertViewStylePlainTextInput;
		[alert setDelegate:self];
        
		alert.tag = 2;
		UITextField* tf = [alert textFieldAtIndex:0];
		tf.keyboardType = UIKeyboardTypeNumberPad;
		[alert show];
	}
    
	[standardUserDefaults synchronize];
	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 2 && buttonIndex == 1) {
		UITextField * alertTextField = [alertView textFieldAtIndex:0];
		@try {
			NSInteger sleepDur = alertTextField.text.integerValue;
			NSDate * datePlusOneMinute = [[NSDate date] dateByAddingTimeInterval:sleepDur * 60];
			AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
			[delegate setSleepTimer:datePlusOneMinute];
		}
		@catch (NSException * exception) {
			DebugLog(@"EXCEPTION!!!! sleep timer");
		}
		@finally {
		}
	}
}

@end
