@class LoginViewController;
@class AudioViewController;
@class CenterPanelTableViewController;
@class DownloadWebViewController;

@interface AudiobookPlayerAppDelegate : UIResponder <UIApplicationDelegate> {
    
}

@property (nonatomic, strong) IBOutlet UIWindow * window;

@property (nonatomic, weak) IBOutlet LoginViewController * viewController;

@property (nonatomic, strong) UIStoryboard * storyboard;

@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;

@property (nonatomic, strong) AudioViewController * currentAudioViewController;
@property (nonatomic, weak) CenterPanelTableViewController * centerPanelController;
@property (nonatomic, strong) DownloadWebViewController * downloadViewController;

-(void)setSleepTimer:(NSDate*)date;
-(void)saveContext;

@end
