//
//  SummaryViewController.m
//  Symphony12
//
//  Created by Michael Toth on 12/15/10.
//  Copyright 2010 Michael Toth. All rights reserved.
//

#import "SummaryViewController.h"
#import "URLCacheAlert.h"
#import "URLCacheConnection.h"
#import "MoreInfoViewController.h"
#import "FullScreenImageViewController.h"
#import "WebViewController.h"
#import "GeneralParser.h"
#import "SHK.h"

@implementation SummaryViewController

@synthesize userID;
@synthesize webSite, fileName, purchase, blowup;
@synthesize buttonTextControl, imageView, notesView, infoView;
@synthesize imageButton, customButton;
@synthesize parseQueue, summaryData, summaryFeedConnection;
@synthesize buttonURL, buttonLabel;

-(void) toggleNetworkIndicator {
	UIApplication *app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = !app.networkActivityIndicatorVisible;
}

- (void)viewDidLoad {
    [self initCache];
    NSString *urlString = [self.webSite stringByAppendingPathComponent:fileName];
    
    // turn on activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // request profile data from the URL specified by webSite/fileName
    NSURLRequest *profileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    self.summaryFeedConnection = [[[NSURLConnection alloc] initWithRequest:profileRequest delegate:self] autorelease];
    
    // start the parse queue
    parseQueue = [NSOperationQueue new];

    // observe notification for 'parserDone'
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parserDone:)
                                                 name:@"parserDone"
                                               object:nil];
    /* a different architecture to keep in mind
    self.imageView.frame = CGRectMake(0,0, 320, 230);
    self.imageView.bounds = CGRectMake(0, 0, 320, 230);
    self.infoView.frame = CGRectMake(0, 240, 160, 230);
    self.infoView.bounds = CGRectMake(0, 480, 160, 230);
    self.notesView.frame = CGRectMake(160, 240, 160, 230);
    self.notesView.bounds = CGRectMake(160, 240, 160, 230);
     */
    [super viewDidLoad];
}



- (void)parserDone:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    // turn off activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // initialize the cache, this sets the path for the cache directory
    [self initCache];
    
    // get the dictionary from userInfo 
    NSDictionary *dict = [notif userInfo];
    
    
    NSString *value;
    self.title = [dict objectForKey:@"title"];
    
    // name of the image file
    value = [dict objectForKey:@"image"];
    imageFileName = value;
    
    // info, notes, and more text
    infoView.text = [dict objectForKey:@"info"];
    notesView.text = [dict objectForKey:@"notes"];
    more = [[NSString alloc] initWithString:[dict objectForKey:@"more"]];
    
    // display the image or load it and display it if it's not loaded yet. 
    NSString *fn = [imageFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *imageURL = [[NSURL alloc] initWithString:[self.webSite  stringByAppendingPathComponent:fn]];
	[self displayImageWithURL:imageURL];
	[imageURL release];
	
    // define button
    // if buttonURL has something
    self.buttonURL = [dict objectForKey:@"buttonURL"];
    self.buttonLabel = [dict objectForKey:@"buttonLabel"];
    
	if (buttonURL.length > 0) {
		// Create button with link to URL
		self.customButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[self.customButton setTitle:buttonLabel forState:UIControlStateNormal];
		self.customButton.frame=CGRectMake(4,10,152,33);
		[self.customButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:self.customButton];
	} else {                        // no button defined, display label instead
		UILabel *label = [[UILabel alloc] init];
		label.text = @"Click on image to view.";
		label.numberOfLines = 1;
		label.adjustsFontSizeToFitWidth = true;
		label.frame = CGRectMake(4,0,152,33);
		[self.view addSubview:label];
		[label release];
	}
    
    
	// Create a final modal view controller for viewing image full screen
    UIButton* modalViewButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [modalViewButton addTarget:self action:@selector(modalViewAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *modalBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:modalViewButton];
    self.navigationItem.rightBarButtonItem = modalBarButtonItem;
    [modalBarButtonItem release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.summaryData = nil;
    self.summaryFeedConnection = nil;
}


- (void)dealloc {
    [self.summaryFeedConnection release];
    [self.summaryData release];
    [parseQueue release];
    [super dealloc];
	[more release];
}

#pragma mark -
#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // check for HTTP status code for proxy authentication failures
    // anything in the 200 to 299 range is considered successful,
    // also make sure the MIMEType is correct:
    //
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSUInteger status;
    NSString *mimeType;
     mimeType = [response MIMEType];
     status = [httpResponse statusCode];
    if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"text/xml"]) {
        self.summaryData = [[NSMutableData alloc] init];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *myerror = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:myerror];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)theerror {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([theerror code] == kCFURLErrorNotConnectedToInternet) {
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:
         NSLocalizedString(@"No Connection Error, you need to be connected to the internet to run Virtual App.",
                           @"For Virtual App to work, you need to be connected to the internet.")
                                    forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        [self handleError:error];
    }
    self.summaryFeedConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.summaryData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.summaryFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    // create parser and initialize with the xml data earlier specified by the connection URL 
    GeneralParser *parseOperation = [[GeneralParser alloc] initWithData:summaryData];
    
    // add the operation to the queue
    [self.parseQueue addOperation:parseOperation];
    [parseOperation release];   
    [summaryData release];
}

- (void)handleError:(NSError *)theerror {
    NSString *errorMessage = [theerror localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Error",
                       @"Problem downloading or parsing sites file.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}



#pragma mark -
#pragma mark URLCacheConnectionDelegate methods

- (void) initCache
{
	/* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"VAPP"];
	
	/* check for existence of cache directory */
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
		return;
	}
	
	/* create a new cache directory */
	if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath
								   withIntermediateDirectories:NO
													attributes:nil
														 error:&error]) {
		URLCacheAlertWithError(error);
		return;
	}
}

- (void) connectionDidFail:(URLCacheConnection *)theConnection
{
	[self stopAnimation];
}


- (void) connectionDidFinish:(URLCacheConnection *)theConnection
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
		[self getFileModificationDate];
		NSComparisonResult result = [theConnection.lastModified compare:fileDate];
		if (result == NSOrderedDescending) {
			/* file is outdated, so remove it */
			if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
				URLCacheAlertWithError(error);
			}
			
		}
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
		/* file doesn't exist, so create it */
		[[NSFileManager defaultManager] createFileAtPath:filePath
												contents:theConnection.receivedData
											  attributes:nil];
		
	}
	
	/* reset the file's modification date to indicate that the URL has been checked */
	
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
	if (![[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:filePath error:&error]) {
		URLCacheAlertWithError(error);
	}
	[dict release];
	
	[self stopAnimation];
	[self displayCachedImage];
}

/* show the user that loading activity has started */

- (void) startAnimation
{
	[activityIndicator startAnimating];
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = YES;
}


/* show the user that loading activity has stopped */

- (void) stopAnimation
{
	[activityIndicator stopAnimating];
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = NO;
}

- (void) displayImageWithURL:(NSURL *)theURL
{
	/* cache update interval in seconds */
	const double URLCacheInterval = 86400.0;
	
	/* get the path to the cached image */
	
	[filePath release]; /* release previous instance */
	fileName = [[theURL path] lastPathComponent];
	filePath = [[dataPath stringByAppendingPathComponent:fileName] retain];
	
	/* apply daily time interval policy */
	
	/* In this program, "update" means to check the last modified date
	 of the image to see if we need to load a new version. */
	
	[self getFileModificationDate];
	/* get the elapsed time since last file update */
	NSTimeInterval time = fabs([fileDate timeIntervalSinceNow]);
	if (time > URLCacheInterval) {
		/* file doesn't exist or hasn't been updated for at least one day */
		[self startAnimation];
		connection = [[URLCacheConnection alloc] initWithURL:theURL delegate:self];
	}
	else {
		//[self startAnimation];
		//connection = [[URLCacheConnection alloc] initWithURL:theURL delegate:self];

		[self displayCachedImage];
	}
}


/* display existing cached image */

- (void) displayCachedImage
{	
	/* display the file as an image */
	
	UIImage *theImage = [[UIImage alloc] initWithContentsOfFile:filePath];
	if (theImage) {
		self.imageView.image = theImage;
	}
	[imageButton setBackgroundImage:theImage forState:UIControlStateNormal];
}

/* get modification date of the current cached image */

- (void) getFileModificationDate
{
	/* default date if file doesn't exist (not an error) */
	fileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		/* retrieve file attributes */
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
		if (attributes != nil) {
			fileDate = [attributes fileModificationDate];
		}
		else {
			URLCacheAlertWithError(error);
		}
	}
}

- (IBAction)modalViewAction:(id)sender
{
	MoreInfoViewController *controller = [[MoreInfoViewController alloc] initWithNibName:@"MoreInfoViewController" bundle:nil];
	controller.delegate = self;
	controller.moreInfo = more;
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (NSString *)myTitle {
	return self.title;
}

- (void)moreInfoViewControllerDidFinish:(MoreInfoViewController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)makePurchase:(id)sender {
	
}

- (IBAction)blowupImage:(id)sender {
	FullScreenImageViewController *fsv = [[FullScreenImageViewController alloc] initWithNibName:@"FullScreenImageViewController" bundle:nil];
	UIImage *myImage = [[UIImage alloc] initWithContentsOfFile:filePath];
	fsv.myImage = myImage;
	[self.navigationController pushViewController:fsv animated:YES];
	[fsv release];	
}

-(void)buttonPressed {
	NSString *urlString = [[NSString alloc] initWithString:buttonURL];
	WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
	webViewController.webSite = self.webSite;
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString release];
	webViewController.urlLocation = url;
	[self.navigationController pushViewController:webViewController animated:YES];
	[webViewController release];
}

@end
