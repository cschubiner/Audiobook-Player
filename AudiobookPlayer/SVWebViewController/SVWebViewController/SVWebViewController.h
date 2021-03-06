//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVModalWebViewController.h"

@interface SVWebViewController : UIViewController

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;

- (void)doneButtonClicked:(id)sender;

@property (nonatomic, strong) UIWebView * webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;

@end
