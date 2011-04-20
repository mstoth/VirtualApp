//
//  MenuViewController.m
//  Symphony12
//
//  Created by Michael Toth on 12/14/10.
//  Copyright 2010 Michael Toth. All rights reserved.
//
/* EXAMPLE XML FILE
 <menu>
 <menuTitle>More Details</menuTitle>
 −
 <image>
 ../../bgimages/1/medium/virtual app icon 512x512.png
 </image>
 −
 <menuItem>
 <itemTitle>Summary Files</itemTitle>
 <pageType>SUMMARY</pageType>
 <fileName>../../summaries/summary2.xml</fileName>
 </menuItem>
 −
 <menuItem>
 <itemTitle>Group Files</itemTitle>
 <pageType>SUMMARY</pageType>
 <fileName>../../summaries/summary3.xml</fileName>
 </menuItem>
 −
 <menuItem>
 <itemTitle>Menu Files</itemTitle>
 <pageType>SUMMARY</pageType>
 <fileName>../../summaries/summary4.xml</fileName>
 </menuItem>
 −
 <menuItem>
 <itemTitle>Web Views</itemTitle>
 <pageType>SUMMARY</pageType>
 <fileName>../../summaries/summary5.xml</fileName>
 </menuItem>
 </menu>
 */

#import "MenuViewController.h"
#import "URLCacheAlert.h"
#import "URLCacheConnection.h"
#import "SummaryViewController.h"
#import "PeopleViewController.h"
#import "WebViewController.h"
#import "ImagesViewController.h"
#import "ContactViewController.h"
#import "Menu.h"
#import "MenuItem.h"
#import "ParseOperation.h"

NSString *kAddMenuItemNotif = @"AddMenuItemNotif";
NSString *kMenuItemResultsKey = @"MenuItemResultsKey";
NSString *kMenuItemErrorNotif = @"MenuItemErrorNotif";
NSString *kMenuItemMsgErrorKey = @"MenuItemMsgErrorKey";

@implementation MenuViewController
@synthesize webSite, fileName, filePath, dataPath;
@synthesize menuTitle, menuItems, pageTypes, fileNames, connection;
@synthesize userID;
@synthesize menuFeedConnection, menuData, parseQueue;
@synthesize menu;
@synthesize myTableView;

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
- (BOOL)hidesBottomBarWhenPushed{
	return true;
}

-(void) toggleNetworkIndicator {
	UIApplication *app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = !app.networkActivityIndicatorVisible;
}

- (id)initWithData:(NSData *)parseData
{
    if ((self = [super init])) {    
        menuData = [parseData copy];
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	menuItems = [[NSMutableArray alloc] init];
	fileNames = [[NSMutableArray alloc] init];
	pageTypes = [[NSMutableArray alloc] init];
	
	NSURL *url = [[[NSURL alloc] initWithString:[webSite stringByAppendingPathComponent:fileName]]autorelease];
	if (url) {
		//NSURLRequest *menuRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[url absoluteString]]];
        NSURLRequest *menuRequest = [NSURLRequest requestWithURL:url];
		//[url release];
		self.menuFeedConnection = [[[NSURLConnection alloc] initWithRequest:menuRequest delegate:self] autorelease];
		NSAssert(self.menuFeedConnection != nil, @"Failure to create URL connection for Menus.");
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		parseQueue = [NSOperationQueue new];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(addMenus:)
													 name:@"AddMenus"
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(menuError:)
													 name:@"MenuError"
												   object:nil];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL failed" message:[webSite stringByAppendingPathComponent:fileName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
/*
	if (!success) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.fileName message:[perror localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
 *//*
	[self initCache];
	self.title = menuTitle;
	NSString *fn = [imageFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *imageURL = [[NSURL alloc] initWithString:[webSite stringByAppendingPathComponent:fn]];
	[self displayImageWithURL:imageURL];
	[imageURL release];
	*/
    [super viewDidLoad];
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
	self.myTableView = nil;
	self.menu = nil;
	self.menuFeedConnection = nil;
	self.menuData = nil;
	self.parseQueue = nil;
	
	self.userID = nil;
	self.connection = nil;
	self.menuTitle = nil;
	self.menuItems = nil;
	self.pageTypes = nil;
	self.fileNames = nil;
	webSite = nil;
	fileName = nil;
	self.filePath = nil;
	self.dataPath = nil;
	
	menuTitle = nil;
	
}


- (void)dealloc {
	[myTableView release];
	[self.menu release];
	[self.menuFeedConnection release];
	[self.menuData release];
	[self.parseQueue release];
	
	[self.userID release];
	[self.connection release];
	[self.menuTitle release];
	[self.menuItems release];
	[self.pageTypes release];
	[fileNames release];
	[webSite release];
	//[self.fileName release];
	[self.filePath release];
	[self.dataPath release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.menuTitle release];
    [super dealloc];
}

- (void)addMenus:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    self.menu = [[notif userInfo] valueForKey:@"menuResult"];
	[self.myTableView reloadData];
	[self initCache];
	self.title = self.menu.title;
	NSString *fn = [self.menu.image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *imageURL = [[NSURL alloc] initWithString:[webSite stringByAppendingPathComponent:fn]];
	[self displayImageWithURL:imageURL];
	[imageURL release];
	//[[NSNotificationCenter defaultCenter] removeObserver:self];
    //[self addMenu:[[notif userInfo] valueForKey:@"menuResult"]];
}


- (void)handleError:(NSError *)theError {
    NSString *errorMessage = [theError localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Error",
                       @"Problem downloading or parsing Menu file.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [self.myTableView reloadData];
}

- (void)menuError:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:@"MenuError"]];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menu.menuItems count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	MenuItem *item = [self.menu.menuItems objectAtIndex:indexPath.row];
	NSString *cellText = item.itemTitle;
	
	cell.textLabel.text = cellText;
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	MenuItem *item = [self.menu.menuItems objectAtIndex:indexPath.row];
	if ([[item pageType] isEqualToString:@"MENU"]) {
		MenuViewController *menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
		menuViewController.webSite = webSite;
		menuViewController.userID = self.userID; 
		menuViewController.fileName = [[item fileName] autorelease];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddMenus" object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MenuError" object:nil];

		[self.navigationController pushViewController:menuViewController animated:YES];
		[menuViewController release];
	}
	if ([[item pageType] isEqualToString:@"SUMMARY"]) {
		SummaryViewController *summaryViewController = [[SummaryViewController alloc] initWithNibName:@"SummaryViewController" bundle:nil];
		summaryViewController.webSite = [webSite autorelease];
		summaryViewController.fileName = [item fileName];
		[self.navigationController pushViewController:summaryViewController animated:YES];
		[summaryViewController release];
	}
	if ([[item pageType] isEqualToString:@"GROUP"]) {
		PeopleViewController *peopleViewController = [[PeopleViewController alloc] initWithNibName:@"PeopleViewController" bundle:nil];
		peopleViewController.webSite = webSite;
		peopleViewController.fileName = [[item fileName] autorelease];
		[self.navigationController pushViewController:peopleViewController animated:YES];
		[peopleViewController release];
	}
	if ([[item pageType] isEqualToString:@"WEBVIEW"]) {
		WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
		webViewController.webSite = webSite;
		NSURL *url = [[NSURL alloc] initWithString:[item fileName]];
		webViewController.urlLocation = url;
		[self.navigationController pushViewController:webViewController animated:YES];
		[webViewController release];
	}
	if ([[item pageType] isEqualToString:@"SLIDESHOW"]) {
		ImagesViewController *slideShowViewController = [[ImagesViewController alloc] initWithNibName:@"ImagesViewController" bundle:nil];
		slideShowViewController.fileName = [item fileName];
		slideShowViewController.webSite = webSite;
		[self.navigationController pushViewController:slideShowViewController animated:YES];
		[slideShowViewController release];
	}
	if ([[item pageType] isEqualToString:@"CONTACT"]) {
		ContactViewController *contactViewController = [[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil];
		contactViewController.userID = self.userID;
		[self.navigationController pushViewController:contactViewController animated:YES];
		[contactViewController release];
	}
	[myTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Cache Connection

- (void) initCache
{
	/* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"VAPP"];
	
	/* check for existence of cache directory */
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.dataPath]) {
		return;
	}
	
	/* create a new cache directory */
	if (![[NSFileManager defaultManager] createDirectoryAtPath:self.dataPath
								   withIntermediateDirectories:NO
													attributes:nil
														 error:&error]) {
		URLCacheAlertWithError(error);
		return;
	}
}
#pragma mark -
#pragma mark URLCacheConnectionDelegate methods (for loading and displaying images)

- (void) connectionDidFail:(URLCacheConnection *)theConnection
{
	[self stopAnimation];
}


- (void) connectionDidFinish:(URLCacheConnection *)theConnection
{
	if (self.filePath && ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath] == YES)) {
		
		/* apply the modified date policy */
		
		[self getFileModificationDate];
		NSComparisonResult result = [theConnection.lastModified compare:fileDate];
		if (result == NSOrderedDescending) {
			/* file is outdated, so remove it */
			if (![[NSFileManager defaultManager] removeItemAtPath:self.filePath error:&error]) {
				URLCacheAlertWithError(error);
			}
			
		}
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath] == NO) {
		/* file doesn't exist, so create it */
		[[NSFileManager defaultManager] createFileAtPath:self.filePath
												contents:theConnection.receivedData
											  attributes:nil];
		
	}
	
	/* reset the file's modification date to indicate that the URL has been checked */
	
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
	if (![[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:self.filePath error:&error]) {
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
	[self.filePath release]; /* release previous instance */
	fileName = [[theURL path] lastPathComponent];
    self.filePath = [self.dataPath stringByAppendingPathComponent:fileName];
	
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
		[self displayCachedImage];
	}
}


/* display existing cached image */

- (void) displayCachedImage
{	
	/* display the file as an image */
	UIImage *theImage = [[UIImage alloc] initWithContentsOfFile:self.filePath];
	if (theImage) {
		UIImageView *iview = [[UIImageView alloc] initWithImage:theImage];
		iview.alpha = 0.3;
		iview.frame = CGRectMake(0, 0, 320, 460);
		[self.view insertSubview:iview atIndex:0];
		[iview release];
		[theImage release];
	}
}

/* get modification date of the current cached image */

- (void) getFileModificationDate
{
	/* default date if file doesn't exist (not an error) */
	fileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
		/* retrieve file attributes */
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:&error];
		if (attributes != nil) {
			fileDate = [attributes fileModificationDate];
		}
		else {
			URLCacheAlertWithError(error);
		}
	}
}


#pragma mark -
#pragma mark NSURLConnection 

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
        self.menuData = [NSMutableData data];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *theError = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:theError
		 ];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)theError {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([theError code] == kCFURLErrorNotConnectedToInternet) {
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:
         NSLocalizedString(@"No Connection Error",
                           @"For Virtual App to work, you need to be connected to the internet.")
                                    forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        [self handleError:theError];
    }
    self.menuFeedConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.menuData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.menuFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    // Spawn an NSOperation to parse the earthquake data so that the UI is not blocked while the
    // application parses the XML data.
    //
    // IMPORTANT! - Don't access or affect UIKit objects on secondary threads.
    //
    ParseOperation *parseOperation = [[ParseOperation alloc] initWithDataAndType:self.menuData type:@"Menu"];
	//parseOperation.objectType = @"Menu";
    [self.parseQueue addOperation:parseOperation];
    [parseOperation release];   // once added to the NSOperationQueue it's retained, we don't need it anymore
    
    // menuData will be retained by the NSOperation until it has finished executing,
    // so we no longer need a reference to it in the main thread.
    self.menuData = nil;
}





@end
