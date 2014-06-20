//
//  DownloadWebViewController.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 6/6/14.
//
//

#import "AudiobookPlayerAppDelegate.h"
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
	NSLog(@"%@", webView.request);
}

- (void)saveFile:(NSURL*)url {
	dispatch_queue_t fetchQueue = dispatch_queue_create("FileDownload fetch", NULL);
	dispatch_async(fetchQueue, ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString * fileExtension = [url pathExtension];
        if ([fileExtension isEqualToString:@"mp3"] || [fileExtension isEqualToString:@"m4p"]) {
            NSString * filename = [url lastPathComponent];
            NSString * docPath = [self downloadsPath];
            NSString * pathToDownloadTo = [NSString stringWithFormat:@"%@/%@", docPath, filename];
            NSData * tmp = [NSData dataWithContentsOfURL:url];
            if (tmp != nil) {
                NSError * error = nil;
                [tmp writeToFile:pathToDownloadTo options:NSDataWritingAtomic error:&error];
                if (error != nil) {
                    NSLog(@"Failed to save the file: %@", [error description]);
                    if ([pathToDownloadTo contains:@".mp3"])
                        [self displayFileDownloadError];
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView * filenameAlert = [[UIAlertView alloc] initWithTitle:@"Download complete" message:[NSString stringWithFormat:@"The audio file %@ has been saved.", filename] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [filenameAlert show];
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    });
                }
            }
            else {
                [self displayFileDownloadError];
            }
        }
        else {
            // File type not supported
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
	NSLog(@"%@", request);
	if ([[[request.URL absoluteString]pathExtension]contains:@"mp3"]) {
		NSLog(@"mp3!!");
		[self saveFile:request.URL.absoluteURL];
		return NO;
	}
    
	return YES;
}

-(BOOL)shouldAutorotate {
	return YES;
}

@end
