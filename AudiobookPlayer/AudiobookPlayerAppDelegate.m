#import "AudiobookPlayerAppDelegate.h"
#import <Parse/Parse.h>

@implementation AudiobookPlayerAppDelegate


#pragma mark - UIApplicationDelegate

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
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	/*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	/*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application {
	/*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
	 */
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
