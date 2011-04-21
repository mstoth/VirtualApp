//
//  MoreInfoViewController.m
//  Symphony12
//
//  Created by Michael Toth on 12/15/10.
//  Copyright 2010 Michael Toth. All rights reserved.
//

#import "MoreInfoViewController.h"
#import "SHK.h"

@implementation MoreInfoViewController
@synthesize textView;
@synthesize delegate;
@synthesize moreInfo;
@synthesize navBar;

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
	textView.text = moreInfo;
	self.title = [delegate myTitle];
    

    [super viewDidLoad];
}

- (IBAction)share:(id)sender
{
	// Create the item to share (in this example, a url)
    SHKItem *item;
    item = [SHKItem text:self.moreInfo];
    
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
	// Display the action sheet
	//[actionSheet showFromToolbar:self.navigationController.toolbar];
    [actionSheet showInView:self.view];
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
	//self.moreInfo = nil;
	//self.textView = nil;
}


- (void)dealloc {
	//[moreInfo release];
	//[textView release];
    [super dealloc];
}

-(IBAction)done:(id)sender {
	[self.delegate moreInfoViewControllerDidFinish:self];
}

@end
