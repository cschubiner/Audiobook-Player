#import "AudioViewController.h"
#import "AudiobookPlayerAppDelegate.h"
#import "DownloadWebViewController.h"
#import "SongDatabase.h"
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>


@implementation AudiobookPlayerAppDelegate


#pragma mark - UIApplicationDelegate

- (void)setupDB {
	SongDatabase * flickrdb = [SongDatabase sharedDefaultSongDatabase];
	AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
	if (flickrdb.managedObjectContext) {
		delegate.managedObjectContext = flickrdb.managedObjectContext;
	}
	else {
		id observer = [NSObject new];
		observer = [[NSNotificationCenter defaultCenter] addObserverForName:FlickrDatabaseAvailable
                                                                     object:flickrdb
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification * note) {
                                                                     delegate.managedObjectContext = flickrdb.managedObjectContext;
                                                                     [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                 }];
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// ****************************************************************************
	// Uncomment and fill in with your Parse credentials:
	[Parse setApplicationId:@"LGNARaSB1vmdvfdPa686s0eZkdmtE7dMQs91QpZp"
                  clientKey:@"Y5i9Ho4nL4DuGYfNq23zsmL0RFP8Mvq2zpD3htiq"];
	//
	// If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
	// described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
	[PFFacebookUtils initializeFacebook];
	// ****************************************************************************
    
	[PFUser enableAutomaticUser];
    
	PFACL * defaultACL = [PFACL ACL];
    
	// If you would like all objects to be private by default, remove this line.
	[defaultACL setPublicReadAccess:YES];
    
	[PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
	// Override point for customization after application launch.
	NSURL * url = (NSURL*)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
	if (url != nil && [url isFileURL]) {
		[self handleOpenURL:url];
	}
    
	self.storyboard = [UIStoryboard storyboardWithName:@"iPhoneStoryboard" bundle:[NSBundle mainBundle]];
	[self setupAudioSession];
	[self setupDB];
    
	if (application.applicationState != UIApplicationStateBackground) {
		// Track an app open here if we launch with a push, unless
		// "content_available" was used to trigger a background push (introduced
		// in iOS 7). In that case, we skip tracking here to avoid double
		// counting the app-open.
		BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
		BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
		BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
			[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
		}
	}
    
	[application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
	 UIRemoteNotificationTypeAlert |
	 UIRemoteNotificationTypeSound];
	return YES;
}

-(void)setupAudioSession
{
	// Set AVAudioSession
	NSError * sessionError = nil;
	//	[[AVAudioSession sharedInstance] setDelegate:self];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    
	// Change the default output audio route
	//	UInt32 doChangeDefaultRoute = 1;
	//	AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
	//	                        sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
}

//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder {
	return YES;
}

-(DownloadWebViewController *)downloadViewController {
	if (!_downloadViewController) {
		//		NSString * startURL = @"https://dl.dropboxusercontent.com/u/46621227/mp3site.html"; //site you can test with. contains a link to an mp3
		NSString * startURL = @"http://google.com";
		_downloadViewController = [[DownloadWebViewController alloc] initWithAddress:startURL];
	}
    
	return _downloadViewController;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	//if it is a remote control event handle it correctly
	if (event.type == UIEventTypeRemoteControl) {
		if (event.subtype == UIEventSubtypeRemoteControlPlay) {
			NSLog(@"UIEventSubtypeRemoteControlPlay");
			[self.currentAudioViewController playAudio:nil];
		}
		else if (event.subtype == UIEventSubtypeRemoteControlPause) {
			NSLog(@"UIEventSubtypeRemoteControlPause");
			[self.currentAudioViewController stopAudio:nil];
		}
		else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
			NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
			[self.currentAudioViewController playPauseAudio:nil];
		}
		else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
			NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");
			[self.currentAudioViewController previousSong:nil];
		}
		else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
			NSLog(@"UIEventSubtypeRemoteControlNextTrack");
			[self.currentAudioViewController nextSong:nil];
		}
	}
}


-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if (url != nil && [url isFileURL]) {
		[self handleOpenURL:url];
	}
    
	return YES;
    
}

- (void)handleOpenURL:(NSURL *)url {
	NSLog(@"url: %@", url);
}


/*
 /
 /
 /
 /
 /
 /
 /
 /
 /
 /
 /
 /
 /
 /
 /
 */


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
	return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
	[PFPush storeDeviceToken:newDeviceToken];
	[PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	if (error.code == 3010) {
		NSLog(@"Push notifications are not supported in the iOS Simulator.");
	}
	else {
		// show some alert or otherwise handle the failure to register.
		NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	[PFPush handlePush:userInfo];
    
	if (application.applicationState == UIApplicationStateInactive) {
		[PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	if (application.applicationState == UIApplicationStateInactive) {
		[PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
	/*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
	[[self managedObjectContext] save:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	/*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
	[[self managedObjectContext] save:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	/*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
	[[self managedObjectContext] save:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	/*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
	 */
	[[self managedObjectContext] save:nil];
	[self.currentAudioViewController.getSong setIsLastPlayed:[NSNumber numberWithBool:FALSE]];
	[[self managedObjectContext] save:nil];
}


#pragma mark - ()

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
	if ([result boolValue]) {
		NSLog(@"AudiobookPlayer successfully subscribed to push notifications on the broadcast channel.");
	}
	else {
		NSLog(@"AudiobookPlayer failed to subscribe to push notifications on the broadcast channel.");
	}
}


@end

