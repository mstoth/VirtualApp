//
//  PeopleViewController.m
//  Symphony12
//
//  Created by Michael Toth on 12/16/10.
//  Copyright 2010 Michael Toth. All rights reserved.
//

#import "PeopleViewController.h"
#import "URLCacheAlert.h"
#import "URLCacheConnection.h"
#import "MoreInfoViewController.h"
#import "FullScreenImageViewController.h"
#import "ParseOperation.h"
#import "Group.h"

@implementation PeopleViewController
@synthesize group, webSite, fileName, infoView, imageView, tableView, imageButton;
@synthesize groupData, parseQueue, groupFeedConnection;
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

-(void) toggleNetworkIndicator {
	UIApplication *app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = !app.networkActivityIndicatorVisible;
}

- (void)groupError:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:@"GroupError"]];
}

- (void)handleError:(NSError *)theError {
    NSString *errorMessage = [theError localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Error",
                       @"Problem downloading or parsing Group file.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    names = [[NSMutableArray alloc] init];
	bios = [[NSMutableArray alloc] init];
	images = [[NSMutableArray alloc] init];
	mores = [[NSMutableArray alloc] init];

    NSURL *url = [[NSURL alloc] initWithString:[webSite stringByAppendingPathComponent:fileName]];
	if (url) {
		NSURLRequest *groupRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[url absoluteString]]];
		[url release];
		self.groupFeedConnection = [[[NSURLConnection alloc] initWithRequest:groupRequest delegate:self] autorelease];
		NSAssert(self.groupFeedConnection != nil, @"Failure to create URL connection for Groups.");
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		parseQueue = [NSOperationQueue new];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(addGroup:)
													 name:@"AddGroup"
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(groupError:)
													 name:@"GroupError"
												   object:nil];
		/*
         
         [self toggleNetworkIndicator];
         NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.menugroupData];
         
         //NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
         [url release];
         [self toggleNetworkIndicator];
         parser.delegate = self;
         success = [parser parse];
         if (!success) {
         perror = [parser parserError];
         }
         [parser release];
		 */
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL failed" message:[webSite stringByAppendingPathComponent:fileName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}    
    
/*
    
	int success;
	names = [[NSMutableArray alloc] init];
	bios = [[NSMutableArray alloc] init];
	images = [[NSMutableArray alloc] init];
	mores = [[NSMutableArray alloc] init];
	
	NSURL *url = [[NSURL alloc] initWithString:[self.webSite stringByAppendingPathComponent:fileName]];
	if (url) {
		[self toggleNetworkIndicator];
		NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
		[self toggleNetworkIndicator];
		[url release];
		parser.delegate = self;
		success = [parser parse];
		[parser release];
		if (!success) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parse failed" message:parser.parserError.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
	} else {
		[url release];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL failed" message:[self.webSite stringByAppendingPathComponent:fileName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	[self initCache];
	if ([bios count]>0)
		infoView.text = [bios objectAtIndex:0];
	if ([mores count]>0) {
		more = [mores objectAtIndex:0];
	}
	if ([images count]>0) {
		NSString *fn = [[images objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSURL *imageURL = [[NSURL alloc] initWithString:[self.webSite stringByAppendingPathComponent:fn]];
		[self displayImageWithURL:imageURL];
		[imageURL release];
	}
	
	// Create a final modal view controller
    UIButton* modalViewButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [modalViewButton addTarget:self action:@selector(modalViewAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *modalBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:modalViewButton];
    self.navigationItem.rightBarButtonItem = modalBarButtonItem;
    [modalBarButtonItem release];
	*/
    
    [super viewDidLoad];
 
}

- (void)addGroup:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    Group *g = (Group *)[[notif userInfo] valueForKey:@"GroupResult"];
    for (GroupItem *gitem in g.groupItems) {
        [names addObject:gitem.name];
        [images addObject:gitem.image];
        [bios addObject:gitem.info];
        [mores addObject:gitem.more];
    }
    
	[self initCache];
	if ([bios count]>0)
		infoView.text = [bios objectAtIndex:0];
	if ([mores count]>0) {
		more = [mores objectAtIndex:0];
	}
	if ([images count]>0) {
		NSString *fn = [[images objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSURL *imageURL = [[NSURL alloc] initWithString:[self.webSite stringByAppendingPathComponent:fn]];
		[self displayImageWithURL:imageURL];
		[imageURL release];
	}
	
	// Create a final modal view controller
    UIButton* modalViewButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [modalViewButton addTarget:self action:@selector(modalViewAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *modalBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:modalViewButton];
    self.navigationItem.rightBarButtonItem = modalBarButtonItem;
    [modalBarButtonItem release];
    
    [tableView reloadData];
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
}


- (void)dealloc {
    [names release];
    [bios release];
    [images release];
    [mores release];
    [parseQueue release];
    [webSite release];
    [super dealloc];
}

#pragma mark -
#pragma mark XML Parser

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
	if (!currentStringValue)
		currentStringValue = [[NSMutableString alloc] initWithString:@""];
	
	if ( [elementName isEqualToString:@"name"] ) {
		[names addObject:currentStringValue];
	}
	if ([elementName isEqualToString:@"image"]) {
		[images addObject:currentStringValue];
	}
	if ([elementName isEqualToString:@"info"]) {
		[bios addObject:currentStringValue];
	}
	if ([elementName isEqualToString:@"more"]) {
		[mores addObject:currentStringValue];
	}
	[currentStringValue release];
	currentStringValue = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentStringValue) {
        // currentStringValue is an NSMutableString instance variable
        currentStringValue = [[NSMutableString alloc] initWithString:string];
    } else {
		[currentStringValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if (currentStringValue) {
		[currentStringValue release];
	}
	currentStringValue = nil;
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
		
		/* apply the modified date policy */
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

- (NSString *)myTitle {
	return self.title;
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
		myImage = theImage;
		[imageButton setImage:myImage forState:UIControlStateNormal];
	}
	[theImage release];
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

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [names count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	cell.textLabel.text = [names objectAtIndex:indexPath.row];
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
	[self initCache];
	self.infoView.text = [bios objectAtIndex:indexPath.row];
	more = [mores objectAtIndex:indexPath.row];
	NSString *img = [images objectAtIndex:indexPath.row];
	NSString *fn = [img stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *wsite = [self.webSite stringByAppendingPathComponent:fn];
	NSURL *imageURL = [[NSURL alloc] initWithString:wsite];
	[self displayImageWithURL:imageURL];
	[imageURL release];
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


- (void)moreInfoViewControllerDidFinish:(MoreInfoViewController *)controller {    
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) viewPicture:(id)sender {
	
	FullScreenImageViewController *fsv = [[FullScreenImageViewController alloc] initWithNibName:@"FullScreenImageViewController" bundle:nil];
	fsv.myImage = myImage;
	[self.navigationController pushViewController:fsv animated:YES];
	[fsv release];
}

#pragma mark -
#pragma mark NSURLConnection 

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // check for HTTP status code for proxy authentication failures
    // anything in the 200 to 299 range is considered successful,
    // also make sure the MIMEType is correct:
    //
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	//NSUInteger status;
	//NSString *mimeType;
	// mimeType = [response MIMEType];
	// status = [httpResponse statusCode];
    if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"application/xml"]) {
        self.groupData = [NSMutableData data];
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
    self.groupFeedConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [groupData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.groupFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    ParseOperation *parseOperation = [[ParseOperation alloc] initWithDataAndType:self.groupData type:@"Group"];
    [self.parseQueue addOperation:parseOperation];
    [parseOperation release];   
    
    self.groupData = nil;
}



@end
