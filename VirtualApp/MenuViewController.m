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
@synthesize webSite, rootSite, fileName, imageFileName, filePath, dataPath;
@synthesize menuTitle, menuType, pageTypes, fileNames, connection;
@synthesize userID;
@synthesize menuFeedConnection, menuData;
@synthesize menu;
@synthesize myTableView;
@synthesize banner;



- (void)setPaths:(NSString *)web root:(NSString *)root fname:(NSString *)fname {
    self.webSite = web;
    self.rootSite = root;
    self.fileName = fname;
}


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
    NSLog(@"viewDidLoad");
    NSURL *url;
    if ([self.fileName isEqualToString:@"mainmenu.xml"]) 
        url = [[NSURL alloc] initWithString:[webSite stringByAppendingPathComponent:self.fileName]];
    else {
        url = [[NSURL alloc] initWithString:[rootSite stringByAppendingPathComponent:self.fileName]];
    }
	if (url) {
        NSURLRequest *menuRequest = [NSURLRequest requestWithURL:url];
		[url release];
		self.menuFeedConnection = [[NSURLConnection alloc] initWithRequest:menuRequest delegate:self];
		NSAssert(self.menuFeedConnection != nil, @"Failure to create URL connection for Menus.");
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL failed" message:[rootSite stringByAppendingPathComponent:self.fileName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}

    [super viewDidLoad];
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
	self.myTableView = nil;
	
}


- (void)dealloc {
     NSLog(@"MenuViewController:dealloc ");
	[myTableView release];
    [menuItems release];
    [currentMenuItem release];
    [dataPath release];
    [filePath release];
    [self.webSite release];
    [self.rootSite release];
    //[self.fileName release];
    [imageFileName release];
    [menuTitle release];
    //NSLog( @"releasing imageFileName: %d",[self.imageFileName retainCount]);
    //[self.imageFileName release];
    [currentStringValue release];
	[connection release];
    [super dealloc];

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
    return [menuItems count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // NSLog(@"MenuViewController:cellForRowAtIndexPath - menuItems retain count = %d, self.menu retainCount = %d",[menuItems retainCount],[self.menu retainCount]);
	// Configure the cell.
	MenuItem *item = [menuItems objectAtIndex:indexPath.row];
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
	MenuItem *item = [menuItems objectAtIndex:indexPath.row];
	if ([[item pageType] isEqualToString:@"MENU"]) {
		MenuViewController *menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
        [menuViewController setPaths:webSite root:self.rootSite fname:[item fileName]];
		menuViewController.userID = self.userID; 
        
		[self.navigationController pushViewController:menuViewController animated:YES];
		[menuViewController release];
	}
	if ([[item pageType] isEqualToString:@"SUMMARY"]) {
		SummaryViewController *summaryViewController = [[SummaryViewController alloc] initWithNibName:@"SummaryViewController" bundle:nil];
        [summaryViewController setPaths:webSite root:self.rootSite fileName:[item fileName]];
		[self.navigationController pushViewController:summaryViewController animated:YES];
		[summaryViewController release];
	}
	if ([[item pageType] isEqualToString:@"GROUP"]) {
		PeopleViewController *peopleViewController = [[PeopleViewController alloc] initWithNibName:@"PeopleViewController" bundle:nil];
        [peopleViewController setPaths:webSite root:self.rootSite fileName:[item fileName]];
		[self.navigationController pushViewController:peopleViewController animated:YES];
		[peopleViewController release];
	}
	if ([[item pageType] isEqualToString:@"WEBVIEW"]) {
		WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
		webViewController.webSite = webSite;
		NSURL *url = [[NSURL alloc] initWithString:[item fileName]];
		webViewController.urlLocation = [url retain];
        [url release];
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
	// NSLog(@"MenuViewController: Finished loading image");
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath] == NO) {
		/* file doesn't exist, so create it */
		[[NSFileManager defaultManager] createFileAtPath:self.filePath
												contents:theConnection.receivedData
											  attributes:nil];
		
	}
	
	/* reset the file's modification date to indicate that the URL has been checked */
	
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
    // NSLog(@"self.filePath: %@",self.filePath);
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
    //NSString *fp;
    //fp = self.filePath;
	UIImage *theImage = [[[UIImage alloc] initWithContentsOfFile:self.filePath] autorelease];
	if (theImage) {
        UIImageView *theImageView = [[UIImageView alloc] initWithImage:theImage];
        // NSLog(@"MenuViewController:displayCachedImage - %@",self.menuType);
        //if ([self.menu.menutype isEqualToString:@"1"]) {
            UIImageView *iview = [[UIImageView alloc] initWithImage:theImage];
            iview.alpha = 0.3;
            iview.frame = CGRectMake(0, 0, 320, 460);
            [self.view insertSubview:iview atIndex:0];
            [iview release];
            CGRect frame = self.myTableView.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            self.myTableView.frame = frame;            
            [self.view setNeedsDisplay];
       // } else {
         //   self.myTableView.tableHeaderView = theImageView;
       // }
        [theImageView release];
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
//	NSUInteger status;
//	NSString *mimeType;
//	mimeType = [response MIMEType];
//	status = [httpResponse statusCode];
    if ((([httpResponse statusCode]/100) == 2) && ([[response MIMEType] isEqual:@"application/xml"] || [[response MIMEType] isEqual:@"text/xml"]) ) {
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
    [self.menuFeedConnection release];
    self.menuFeedConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.menuData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.menuFeedConnection release];
    self.menuFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    // NSLog(@"MenuViewController: finished loading data, starting to parse.");
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.menuData];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
    [self.myTableView reloadData];
    [self initCache];
    
	NSString *fn = [self.imageFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"Set fn: %d",[self.imageFileName retainCount]);
	NSURL *imageURL = [[NSURL alloc] initWithString:[rootSite stringByAppendingPathComponent:fn]];
    self.filePath = [self.dataPath stringByAppendingPathComponent:[fn lastPathComponent]];

	[self displayImageWithURL:imageURL];
	[imageURL release];

    self.menuData = nil;
}

#pragma mark -
#pragma mark NSXMLParser delegate routines

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"menu"]) {
        menuItems = [[NSMutableArray alloc] init];
        // NSLog(@"menuItems retain count after init is %d",[menuItems retainCount]);
        
    }
    if ([elementName isEqualToString:@"menuItem"]) {
        currentMenuItem = [[MenuItem alloc] init];
    }
    if ([elementName isEqualToString:@"fileName"] ||
        [elementName isEqualToString:@"menuTitle"] ||
        [elementName isEqualToString:@"pageType"] ||
        [elementName isEqualToString:@"itemTitle"] ||
        [elementName isEqualToString:@"menutype"] ||
        [elementName isEqualToString:@"image"]) {
        accumulatingChars = YES;
        currentStringValue = [[NSMutableString alloc] init];
        // NSLog(@"Allocated currentStringValue: %d",[currentStringValue retainCount]);

    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {   
    
    if ([elementName isEqualToString:@"menuItem"]) {
        // NSLog(@"MenuParserDelegate:didEndElement - menuItems retain count before adding object is %d",[self.menuItems retainCount]);
        [menuItems addObject:currentMenuItem];
        // NSLog(@"MenuParserDelegate:didEndElement - menuItems retain count after adding object is %d",[self.menuItems retainCount]);
        [currentMenuItem release];
        currentMenuItem = nil;
    }
    if ([elementName isEqualToString:@"pageType"]) {
        currentMenuItem.pageType = currentStringValue;
    }
    if ([elementName isEqualToString:@"fileName"]) {
        currentMenuItem.fileName = currentStringValue;
    }
    if ([elementName isEqualToString:@"itemTitle"]) {
        currentMenuItem.itemTitle = currentStringValue;
    }
    if ([elementName isEqualToString:@"menuTitle"]) {
        self.menuTitle = currentStringValue;
    }
    if ([elementName isEqualToString:@"menutype"]) {
        self.menuType = currentStringValue;
    }
    if ([elementName isEqualToString:@"image"]) {
        //NSLog(@"Setting imageFileName: %d",[self.imageFileName retainCount]);
        self.imageFileName = currentStringValue;
        //NSLog(@"Set imageFileName: %d",[self.imageFileName retainCount]);
    }
    //NSLog( @"releasing currentString Value, %d",[currentStringValue retainCount]);
    [currentStringValue release];
    currentStringValue = nil;
    accumulatingChars = NO;
}



- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingChars) {
        [currentStringValue appendString:string];
       // NSLog(@"Added to currentStringValue: %d",[currentStringValue retainCount]);
    }
}




@end
