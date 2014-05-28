//
//  LoginViewController.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/27/14.
//
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
    
	return self;
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	PFUser * currentUser = [PFUser currentUser];
	if (currentUser && [currentUser objectForKey:@"name"]) {
		[self performLoginSegue];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)performLoginSegue {
	[self performSegueWithIdentifier:@"loginSegue" sender:nil];
}

- (IBAction)touchedSkipButton:(id)sender {
	[PFAnonymousUtils logInWithBlock:^(PFUser * user, NSError * error) {
        if (error) {
            NSLog(@"Anonymous login failed.");
        }
        else {
            NSLog(@"Anonymous user logged in.");
            [self performLoginSegue];
        }
    }];
}

- (IBAction)touchedLoginButton:(id)sender {
	[PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser * user, NSError * error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        }
        else {
            if (user.isNew) {
                NSLog(@"User signed up through Facebook!");
                [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection * connection, id result, NSError * error) {
                    if (!error) {
                        // Store the current user's Facebook information on the user
                        [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"fbId"];
                        [[PFUser currentUser] setObject:[result objectForKey:@"name"] forKey:@"name"];
                        [[PFUser currentUser] setObject:[result objectForKey:@"email"] forKey:@"email"];
                        [[PFUser currentUser] saveInBackground];
                        [self performLoginSegue];
                    }
                }];
            }
            else {
                [self performLoginSegue];
            }
            
            NSLog(@"User logged in through Facebook!");
        }
    }];
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
