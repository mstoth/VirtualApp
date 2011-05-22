//
//  WebViewController.m
//  Symphony12
//
//  Created by Michael Toth on 12/17/10.
//  Copyright 2010 Michael Toth. All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController
@synthesize webSite, fileName, webView, urlLocation;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:self.urlLocation];
	[self.webView loadRequest:urlRequest];
	[urlLocation release];
	[urlRequest release];
    [super viewDidLoad];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (YES);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.fileName = nil;
    self.webSite = nil;
    self.urlLocation = nil;
}


- (void)dealloc {
    [fileName release];
    [webSite release];
    [urlLocation release];
    [super dealloc];
}


@end
