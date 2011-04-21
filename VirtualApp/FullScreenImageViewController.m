//
//  FullScreenImageViewController.m
//  Symphony12
//
//  Created by Michael Toth on 12/18/10.
//  Copyright 2010 Michael Toth. All rights reserved.
//

#import "FullScreenImageViewController.h"
#import "SHK.h"


@implementation FullScreenImageViewController
@synthesize myImage, imageButton, imageView;
@synthesize buttonURL, buttonLabel;

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
	self.imageView.image = self.myImage;
    UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                     target:self
                                                                                     action:@selector(share)];
    self.navigationItem.rightBarButtonItem = shareButtonItem;
    [shareButtonItem release];

    [super viewDidLoad];
}

- (void)share
{
    SHKItem *item;
    item = [SHKItem image:self.myImage title:self.title];
    
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
	// Display the action sheet
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.buttonURL = nil;
    self.buttonLabel = nil;

}


- (void)dealloc {
    [buttonLabel release];
    [buttonURL release];

    [super dealloc];
}

- (IBAction)done:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}


@end
