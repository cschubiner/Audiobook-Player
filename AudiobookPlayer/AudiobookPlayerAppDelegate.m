#import "AudioViewController.h"
#import "AudiobookPlayerAppDelegate.h"
#import "CenterPanelTableViewController.h"
#import "DownloadWebViewController.h"
#import "SongDatabase.h"
#import <AVFoundation/AVFoundation.h>

@interface AudiobookPlayerAppDelegate ()
@end

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
    
	self.storyboard = [UIStoryboard storyboardWithName:@"iPhoneStoryboard" bundle:[NSBundle mainBundle]];
    //    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
	[self setupAudioSession];
	[self setupDB];
    
	
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
			DebugLog(@"UIEventSubtypeRemoteControlPlay");
			[self.currentAudioViewController playAudio:nil];
		}
		else if (event.subtype == UIEventSubtypeRemoteControlPause) {
			DebugLog(@"UIEventSubtypeRemoteControlPause");
			[self.currentAudioViewController stopAudio:nil];
		}
		else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
			DebugLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
			[self.currentAudioViewController playPauseAudio:nil];
		}
		else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
			DebugLog(@"UIEventSubtypeRemoteControlPreviousTrack");
			[self.currentAudioViewController skipWithDuration:-30];
		}
		else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
			DebugLog(@"UIEventSubtypeRemoteControlNextTrack");
			[self.currentAudioViewController skipWithDuration:30];
		}
	}
}

NSDate * sleepDate;
NSTimer * timer11;

-(void)checkSleepTimer {
	DebugLog(@"aaaa");
	if (!sleepDate) return;
    
	if ([[NSDate date] compare:sleepDate] == NSOrderedDescending) {
		DebugLog(@"aaab");
		[timer11 invalidate];
		timer11 = nil;
		DebugLog(@"aaac");
		sleepDate = nil;
		DebugLog(@"Stopping music because of timer");
		[self.currentAudioViewController stopAudio:nil];
		DebugLog(@"aaad");
	}
    
	DebugLog(@"aaae");
}

-(void)setSleepTimer:(NSDate *)date {
	sleepDate = date;
	if (!timer11) {
		timer11 = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(checkSleepTimer) userInfo:nil repeats:YES];
	}
}


-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if (url != nil && [url isFileURL]) {
		[self handleOpenURL:url];
	}
    
	return YES;
    
}

- (void)handleOpenURL:(NSURL *)url {
	DebugLog(@"url: %@", url);
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



- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	if (error.code == 3010) {
		DebugLog(@"Push notifications are not supported in the iOS Simulator.");
	}
	else {
		// show some alert or otherwise handle the failure to register.
		DebugLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
	/*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
	[((AudiobookPlayerAppDelegate*)[UIApplication sharedApplication].delegate)saveContextAndForce : YES];
    
}

BOOL canSave;


-(void)saveContextAndForce:(BOOL)shouldForce {
    canSave = true;
	if (canSave || shouldForce) {
        
		NSManagedObjectContext * context = self.managedObjectContext;
		if (!context) {
			DebugLog(@"NO CONTEXT!");
			return;
		}
        
		@try {
			[self.currentAudioViewController recordCurrNoSave];
		}
		@catch (NSException * exception) {
			DebugLog(@"exception: %@", exception);
		}
		@finally {
		}
        
		NSError * error;
		BOOL success = [context save:&error];
		if (error || !success) {
			DebugLog(@"success: %@ - error: %@", success ? @"true" : @"false", error);
            //			abort();
		}
        
		[context performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];
		[context performSelector:@selector(save:) withObject:nil afterDelay:1.0];
		[context setStalenessInterval:6.0];
		while (context) {
			[context performBlock:^(){
                NSError * error;
                bool success =  [context save:&error];
                if (error || !success)
                    DebugLog(@"success: %@ - error: %@", success ? @"true" : @"false", error);
                
            }];
			context = context.parentContext;
		}
        
		//		[self pStore];
		DebugLog(@"successful save!");
		canSave = false;
	}
    
	//	else DebugLog(@"not saving");
}

//-(void)pStore {
//	NSPersistentStoreCoordinator * psc = self.managedObjectContext.persistentStoreCoordinator;
//
//	NSMutableDictionary * pragmaOptions = [NSMutableDictionary dictionary];
//	[pragmaOptions setObject:@"FULL" forKey:@"synchronous"];
//	[pragmaOptions setObject:@"2" forKey:@"fullfsync"];
//
//	NSDictionary * storeOptions =
//    [NSDictionary dictionaryWithObject:pragmaOptions forKey:NSSQLitePragmasOption];
//	NSPersistentStore * store;
//	NSError * error = nil;
//	store = [psc addPersistentStoreWithType:NSSQLiteStoreType
//                              configuration:nil
//                                        URL:((NSPersistentStore*)psc.persistentStores[0]).URL
//                                    options:storeOptions
//                                      error:&error];
//}

-(void)saveContext {
	[self saveContextAndForce:NO];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	[self checkSleepTimer];
	[self saveContextAndForce:YES];
	completionHandler(UIBackgroundFetchResultNoData);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	/*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
	[((AudiobookPlayerAppDelegate*)[UIApplication sharedApplication].delegate)saveContextAndForce : YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	/*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
	[((AudiobookPlayerAppDelegate*)[UIApplication sharedApplication].delegate)saveContext];
	[self.centerPanelController refreshTableView];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	/*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
	 */
	[self.currentAudioViewController.getSong setIsLastPlayed:[NSNumber numberWithBool:FALSE]];
	[((AudiobookPlayerAppDelegate*)[UIApplication sharedApplication].delegate)saveContextAndForce : YES];
}


@end

