//
//  ImagePageViewController.m
//  VirtualApp
//
//  Created by Michael Toth on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImagePageViewController.h"
#import "URLCacheConnection.h"
#import "URLCacheAlert.h"
#import "SHK.h"


@implementation ImagePageViewController
@synthesize fileName, imageView, imageID, imageFileName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [self.imageView release];
    [fileName release];
    [self.imageFileName release];
    [self.imageID release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createCustomActivityIndicator];
    // Do any additional setup after loading the view from its nib.
    // fileName contains the path for the xml data
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(share:)];  
    
    self.navigationItem.rightBarButtonItem = anotherButton;
    [anotherButton release];
#ifdef LOCAL
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://localhost:3000/%@",
                           self.fileName];
#else
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://home.my-iphone-app.com/%@",
                           self.fileName];
#endif
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
    [data release];
    [url release];
    // now the image file name should be located in imageFileName and the id is imageID
#ifdef DEBUG
    NSLog(@"Image file name is %@",imageFileName);
    NSLog(@"Image ID is %@", imageID);
#endif
    
#ifdef LOCAL
    urlString = [[NSString alloc] initWithFormat:@"http://localhost:3000/system/imgs/%@/original/%@",self.imageID, [self.imageFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
#else
    urlString = [[NSString alloc] initWithFormat:@"http://home.my-iphone-app.com/system/imgs/%@/original/%@", self.imageID, [self.imageFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
#endif
    [self initCache];
    url = [[NSURL alloc] initWithString:urlString];
	[self displayImageWithURL:url];
	[url release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.imageView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark NSXMLParser delegate routines

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"img-file-name"] || [elementName isEqualToString:@"id"]) {
        accumulatingChars = YES;
        currentStringValue = [[NSMutableString alloc] init];        
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {   
    
    if ([elementName isEqualToString:@"img-file-name"]) {
        self.imageFileName = currentStringValue;
    }
    if ([elementName isEqualToString:@"id"]) {
        self.imageID = currentStringValue;
    }
    [currentStringValue release];
    currentStringValue = nil;
    accumulatingChars = NO;
}



- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingChars) {
        [currentStringValue appendString:string];
    }
}


- (IBAction)share:(id)sender
{
	// Create the item to share (in this example, a url)
    SHKItem *item;
    item = [SHKItem image:self.imageView.image title:self.fileName ];
    
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
	// Display the action sheet
	//[actionSheet showFromToolbar:self.navigationController.toolbar];
    [actionSheet showInView:self.view];
}


- (void) displayImageWithURL:(NSURL *)theURL
{
	/* cache update interval in seconds */
	const double URLCacheInterval = 86400.0;
	
	/* get the path to the cached image */
	
	[filePath release]; /* release previous instance */
	imageFileNameWithoutPath = [[theURL path] lastPathComponent];
	filePath = [[dataPath stringByAppendingPathComponent:imageFileNameWithoutPath] retain];
	
	/* apply daily time interval policy */
	
	/* In this program, "update" means to check the last modified date
	 of the image to see if we need to load a new version. */
	
	[self getFileModificationDate];
	/* get the elapsed time since last file update */
	NSTimeInterval time = fabs([fileDate timeIntervalSinceNow]);
	if (time > URLCacheInterval) {
		/* file doesn't exist or hasn't been updated for at least one day */
		[self startAnimation];
		myConnection = [[URLCacheConnection alloc] initWithURL:theURL delegate:self];
	}
	else {
		//[self startAnimation];
		//connection = [[URLCacheConnection alloc] initWithURL:theURL delegate:self];
        
		[self displayCachedImage];
	}
}


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



/* display existing cached image */

- (void) displayCachedImage
{	
	/* display the file as an image */
	
	UIImage *theImage = [[UIImage alloc] initWithContentsOfFile:filePath];
	if (theImage) {
		self.imageView.image = theImage;
	}
    [imageView setImage:theImage];
}

/* get modification date of the current cached image */

-(void) createCustomActivityIndicator {
    customActivityIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(100, 200, 100.0, 100.0)];
    customActivityIndicator.animationImages = [NSArray arrayWithObjects:
                                               [UIImage imageNamed:@"0001.png"],
                                               [UIImage imageNamed:@"0002.png"],
                                               [UIImage imageNamed:@"0003.png"],
                                               [UIImage imageNamed:@"0004.png"],
                                               [UIImage imageNamed:@"0005.png"],
                                               [UIImage imageNamed:@"0006.png"],
                                               [UIImage imageNamed:@"0007.png"],
                                               [UIImage imageNamed:@"0008.png"],
                                               [UIImage imageNamed:@"0009.png"],
                                               [UIImage imageNamed:@"0010.png"],
                                               [UIImage imageNamed:@"0011.png"],
                                               [UIImage imageNamed:@"0012.png"],
                                               [UIImage imageNamed:@"0013.png"],
                                               [UIImage imageNamed:@"0014.png"],
                                               [UIImage imageNamed:@"0015.png"],
                                               [UIImage imageNamed:@"0016.png"],
                                               nil];
    [self.view addSubview:customActivityIndicator];
    customActivityIndicator.animationDuration = 1.0;
    customActivityIndicator.animationRepeatCount = 0;
}

/* show the user that loading activity has started */

- (void) startAnimation
{
	[activityIndicator startAnimating];
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = YES;
    [customActivityIndicator startAnimating];
}


/* show the user that loading activity has stopped */

- (void) stopAnimation
{
	[activityIndicator stopAnimating];
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = NO;
    [customActivityIndicator stopAnimating];
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
	[myConnection release];
    myConnection = nil;
	[self stopAnimation];
	[self displayCachedImage];
}

@end
