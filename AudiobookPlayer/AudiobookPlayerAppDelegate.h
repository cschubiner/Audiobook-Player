@class LoginViewController;
@class AudioViewController;

@interface AudiobookPlayerAppDelegate : UIResponder <UIApplicationDelegate> {
    
}

@property (nonatomic, strong) IBOutlet UIWindow * window;

@property (nonatomic, weak) IBOutlet LoginViewController * viewController;

@property (nonatomic, strong) UIStoryboard * storyboard;

@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;

@property (nonatomic, strong) AudioViewController * currentAudioViewController;

@end
