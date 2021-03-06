//
//  DownloadWebViewController.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 6/6/14.
//
//

#import "AudiobookPlayerAppDelegate.h"
#import "CenterPanelTableViewController.h"
#import "DownloadWebViewController.h"
#import "NSString+Addons.h"
#import "SVWebViewController.h"

@interface DownloadWebViewController ()

@end

@implementation DownloadWebViewController


-(id)initWithAddress:(NSString *)urlString {
	id ret = [super initWithAddress:urlString];
	[self.webViewController.webView setDelegate:self];
	return ret;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.webViewController webViewDidFinishLoad:webView];
	DebugLog(@"%@", webView.request);
}

-(BOOL)isValidExtension:(NSString*)fileExtension {
	return [fileExtension isEqualToString:@"mp3"] || [fileExtension isEqualToString:@"wma"] || [fileExtension isEqualToString:@"wav"] || [fileExtension isEqualToString:@"aac"] || [fileExtension isEqualToString:@"ape"] || [fileExtension isEqualToString:@"flac"] || [fileExtension isEqualToString:@"m4p"] || [fileExtension isEqualToString:@"alac"];
}

- (void)saveFile:(NSURL*)url {
	dispatch_queue_t fetchQueue = dispatch_queue_create("FileDownload fetch", NULL);
	dispatch_async(fetchQueue, ^{
        NSString * fileExtension = [url pathExtension];
        if ([self isValidExtension:fileExtension]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                UIAlertView * filenameAlert = [[UIAlertView alloc] initWithTitle:@"Initializing download" message:@"Your download is currently in progress" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [filenameAlert show];
            });
            
            NSString * filename = [url lastPathComponent];
            NSString * docPath = [self downloadsPath];
            NSString * pathToDownloadTo = [NSString stringWithFormat:@"%@/%@", docPath, filename];
            NSData * tmp = [NSData dataWithContentsOfURL:url];
            if (tmp != nil) {
                NSError * error = nil;
                [tmp writeToFile:pathToDownloadTo options:NSDataWritingAtomic error:&error];
                if (error != nil) {
                    DebugLog(@"Failed to save the file: %@", [error description]);
                    if ([self isValidExtension:fileExtension])
                        [self displayFileDownloadError];
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        AudiobookPlayerAppDelegate * delegate = [UIApplication sharedApplication].delegate;
                        [delegate.centerPanelController refreshTableView];
                        UIAlertView * filenameAlert = [[UIAlertView alloc] initWithTitle:@"Download complete" message:[NSString stringWithFormat:@"The audio file %@ has been saved.", filename] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [filenameAlert show];
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    });
                }
            }
            else {
                if ([self isValidExtension:fileExtension])
                    [self displayFileDownloadError];
            }
        }
        else {
            // File type not supported
            if ([self isValidExtension:fileExtension])
                [self displayFileDownloadError];
        }
    });
}

-(void)displayFileDownloadError {
	dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView * filenameAlert = [[UIAlertView alloc] initWithTitle:@"Download failed" message:@"Your file failed to download" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [filenameAlert show];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
}


- (NSString *)downloadsPath {
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectoryPath = [paths objectAtIndex:0];
    
	NSString * downloadsPath = [documentsDirectoryPath stringByAppendingPathComponent:@"/Downloads"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:downloadsPath])
		[[NSFileManager defaultManager] createDirectoryAtPath:downloadsPath withIntermediateDirectories:NO attributes:nil error:nil];
    
	return downloadsPath;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	DebugLog(@"%@", request);
	if ([self isValidExtension:[[request.URL absoluteString]pathExtension]]) {
		DebugLog(@"mp3!!");
		[self saveFile:request.URL.absoluteURL];
		return NO;
	}
    
	return YES;
}

-(BOOL)shouldAutorotate {
	return YES;
}

@end
