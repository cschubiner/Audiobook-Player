//
//  MainViewController.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/27/14.
//
//

#import "AudiobookPlayerAppDelegate.h"
#import "PanelsViewController.h"
#import "SongDatabase.h"

@interface PanelsViewController ()

@end

@implementation PanelsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
    
	return self;
}

-(void)awakeFromNib
{
	[self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"leftViewController"]];
	[self setLeftFixedWidth:150];
	[self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"centerViewController"]];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

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
