//
//  PDFWebViewController.m
//  MobileTrek
//
//  Created by Steven Fisher on 8/15/15.
//  Copyright (c) 2015 RecoveryTrek. All rights reserved.
//

#import "PDFWebViewController.h"
#import "MobileTrek-Swift.h"

@interface PDFWebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PDFWebViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Setup WebView
	[self.webView setBackgroundColor:Graphics.backgroundColor];
	[self.webView setScalesPageToFit:YES];
	
	// Get JSON for the PDF and trim values we don't need
	NSString *pdfFile = [[NSUserDefaults standardUserDefaults] objectForKey:@"PDFJson"];
	
	// Write to caching file the PDF file with encoding
	NSData *data = [[NSData alloc] initWithBase64EncodedString:pdfFile options:0];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"cache.pdf"];
	[data writeToFile:docPath atomically:YES];
	
	// Open the file in the webview
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:docPath])
	{
		NSURL *url = [NSURL fileURLWithPath:docPath];
		NSURLRequest *pdfRequest = [NSURLRequest requestWithURL:url];
		[self.webView loadRequest:pdfRequest];
	}
}

@end
