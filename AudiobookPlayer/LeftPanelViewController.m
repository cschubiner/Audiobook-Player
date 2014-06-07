//
//  LeftPanelViewController.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import "LeftPanelViewController.h"
#import "UITableViewCell+FlatUI.h"
#import <FlatUIKit/UIColor+FlatUI.h>

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
	lbNavTitle.textAlignment = UITextAlignmentLeft;
    
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
	return 2;
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
        
		if (isPanMode == 1) {
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
    
	return cell;
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
		UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Color scheme saved"
                                                         message:@"The color scheme will enable next time you start the app."
                                                        delegate:self
                                               cancelButtonTitle:@"Dismiss"
                                               otherButtonTitles:nil];
		[alert show];
	}
    
	[standardUserDefaults synchronize];
	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
