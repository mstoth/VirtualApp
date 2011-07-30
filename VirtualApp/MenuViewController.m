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
#import "ImagePageViewController.h"
#import "TextViewController.h"
#import "Menu.h"
#import "MenuItem.h"
#import "ParseOperation.h"
#import "MenuCell.h"
#import "GCalEventsViewController.h"

NSString *kAddMenuItemNotif = @"AddMenuItemNotif";
NSString *kMenuItemResultsKey = @"MenuItemResultsKey";
NSString *kMenuItemErrorNotif = @"MenuItemErrorNotif";
NSString *kMenuItemMsgErrorKey = @"MenuItemMsgErrorKey";

@implementation MenuViewController
@synthesize webSite, rootSite, fileName, imageFileName, filePath, dataPath;
@synthesize menuTitle, menuType, pageTypes, fileNames, connection;
@synthesize userID;
@synthesize appID;
@synthesize menuFeedConnection, menuData;
@synthesize menu;
@synthesize myTableView;
@synthesize banner;
@synthesize cellView;

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
    [self.view addSubview:customActivityIndicator];
}


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
    // NSLog(@"viewDidLoad");
    //[self createCustomActivityIndicator];
    [[myTableView backgroundView] setAlpha:0.3];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
   // NSLog(@"%@",self.fileName);
    //[menuItems release];
    NSURL *url;
    if ([self.fileName isEqualToString:@"mainmenu.xml"]) 
        url = [[NSURL alloc] initWithString:[webSite stringByAppendingPathComponent:self.fileName]];
    else {
        url = [[NSURL alloc] initWithString:[rootSite stringByAppendingPathComponent:self.fileName]];
    }
#ifdef DEBUG
   NSLog(@"URL = %@",[url absoluteString]);
#endif
	if (url) {
        NSURLRequest *menuRequest = [NSURLRequest requestWithURL:url];
		[url release];
		self.menuFeedConnection = [[NSURLConnection alloc] initWithRequest:menuRequest delegate:self];
		NSAssert(self.menuFeedConnection != nil, @"Failure to create URL connection for Menus.");
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [customActivityIndicator startAnimating];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL failed" message:[rootSite stringByAppendingPathComponent:self.fileName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
    [self displayCachedImage];
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
    [customActivityIndicator release];
	[myTableView release];
    [menuItems release];
    menuItems = nil;
    [currentMenuItem release];
    [dataPath release];
    [filePath release];
    [self.webSite release];
    [self.rootSite release];
    [self.fileName release];
    [self.menuTitle release];
    [self.menuType release];
    [imageFileName release];
    //NSLog( @"releasing imageFileName: %d",[self.imageFileName retainCount]);
    //[self.imageFileName release];
    [currentStringValue release];
    [self.userID release];
    [self.appID release];
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
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    MenuItem *item = [menuItems objectAtIndex:[indexPath row]];
    
    NSString *text = item.description;
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = MAX(size.height, 44.0f);
    return height + (CELL_CONTENT_MARGIN * 2);
}
*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    //UILabel *label=nil,*desc;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // MenuCell *cell = (MenuCell *)[tableView dequeueReusableCellWithIdentifier:@"MenuCell"];

    if (cell == nil) {
        

        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
//        label = [[UILabel alloc] initWithFrame:CGRectZero];
//        [label setLineBreakMode:UILineBreakModeWordWrap];
//        [label setMinimumFontSize:FONT_SIZE];
//        [label setNumberOfLines:0];
//        [label setBackgroundColor:[UIColor clearColor]];
//        [label setFont:[UIFont systemFontOfSize:TITLE_FONT_SIZE]];
//        [label setTag:1];
//        [[cell contentView] addSubview:label];
//        
//        desc = [[UILabel alloc] initWithFrame:CGRectZero];
//        [desc setLineBreakMode:UILineBreakModeWordWrap];
//        [desc setMinimumFontSize:FONT_SIZE];
//        [desc setNumberOfLines:0];
//        [desc setBackgroundColor:[UIColor clearColor]];
//        [desc setFont:[UIFont systemFontOfSize:FONT_SIZE]];
//        [label setTag:2];
//        [[cell contentView] addSubview:desc];

        
    }
    
    //[cell.detailTextLabel setNumberOfLines:2];
    // NSLog(@"MenuViewController:cellForRowAtIndexPath - menuItems retain count = %d, self.menu retainCount = %d",[menuItems retainCount],[self.menu retainCount]);
	// Configure the cell.
    
	MenuItem *item = [menuItems objectAtIndex:indexPath.row];
	NSString *cellText = item.itemTitle;
//    
//    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
//    CGSize size = [cellText sizeWithFont:[UIFont systemFontOfSize:TITLE_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
//    [label setFrame:CGRectMake(CELL_CONTENT_MARGIN, 0, size.width, size.height)];
//    [label setText:cellText];
//    [[cell contentView] addSubview:label];
//    
//    CGSize dsize = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
//    [desc setFrame:CGRectMake(CELL_CONTENT_MARGIN, size.height, size.width, size.height)];
//    [desc setText:text];
//    [[cell contentView] addSubview:desc];
    
//    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
//    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
//    
//    NSLog(@"%@",item.description);
//    
//    cell.textLabel.text = cellText;
//    if (!label)
//        label = (UILabel*)[cell viewWithTag:1];
//    
//    [label setText:item.description];
//    [label setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN+40.0f, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];
    //[cell.detailTextLabel setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];
    [cell.detailTextLabel setTextColor:[UIColor blackColor]];
    [cell.detailTextLabel setText:item.description];
    [cell.textLabel setText:cellText];
    
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
    NSString *iFileName;
	MenuItem *item = [menuItems objectAtIndex:indexPath.row];
    if ([[item pageType] isEqualToString:@"CALENDAR"]) {
		GCalEventsViewController *calViewController = [[GCalEventsViewController alloc] initWithNibName:@"GCalEventsViewController" bundle:nil];
		calViewController.appID = self.appID;
        calViewController.filename = item.fileName;
#ifdef DEBUG
        NSLog(@"app ID is %@ and filename is %@",self.appID,item.fileName);
#endif
		[self.navigationController pushViewController:calViewController animated:YES];
		[calViewController release];
	}
    if ([item fileName]) {
        iFileName = [[NSString alloc] initWithString:[item fileName]];
    } else {
        iFileName = nil;
    }
	if ([[item pageType] isEqualToString:@"MENU"]) {
		MenuViewController *menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
        [menuViewController setPaths:webSite root:self.rootSite fname:iFileName];
		menuViewController.userID = self.userID; 
        menuViewController.appID = self.appID;
		[self.navigationController pushViewController:menuViewController animated:YES];
		[menuViewController release];
	}
	if ([[item pageType] isEqualToString:@"SUMMARY"]) {
		SummaryViewController *summaryViewController = [[SummaryViewController alloc] initWithNibName:@"SummaryViewController" bundle:nil];
        [summaryViewController setPaths:webSite root:self.rootSite fileName:iFileName];
		[self.navigationController pushViewController:summaryViewController animated:YES];
		[summaryViewController release];
	}
	if ([[item pageType] isEqualToString:@"TEXTPAGE"]) {
		TextViewController *textViewController = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
        textViewController.fileName=iFileName;
		[self.navigationController pushViewController:textViewController animated:YES];
		[textViewController release];
	}
	if ([[item pageType] isEqualToString:@"GROUP"]) {
		PeopleViewController *peopleViewController = [[PeopleViewController alloc] initWithNibName:@"PeopleViewController" bundle:nil];
        [peopleViewController setPaths:webSite root:self.rootSite fileName:iFileName];
		[self.navigationController pushViewController:peopleViewController animated:YES];
		[peopleViewController release];
	}
	if ([[item pageType] isEqualToString:@"WEBVIEW"]) {
		WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
		webViewController.webSite = webSite;
		NSURL *url = [[NSURL alloc] initWithString:iFileName];
		webViewController.urlLocation = [url retain];
        [url release];
		[self.navigationController pushViewController:webViewController animated:YES];
		[webViewController release];
	}
	if ([[item pageType] isEqualToString:@"SLIDESHOW"]) {
		ImagesViewController *slideShowViewController = [[ImagesViewController alloc] initWithNibName:@"ImagesViewController" bundle:nil];
		slideShowViewController.fileName = iFileName;
		slideShowViewController.webSite = webSite;
		[self.navigationController pushViewController:slideShowViewController animated:YES];
		[slideShowViewController release];
	}
    if ([[item pageType] isEqualToString:@"IMAGEPAGE"]) {
        ImagePageViewController *fsc = [[ImagePageViewController alloc] initWithNibName:@"ImagePageViewController" bundle:nil];
        fsc.fileName = iFileName;
        [self.navigationController pushViewController:fsc animated:YES];
        [fsc release];
    }
	if ([[item pageType] isEqualToString:@"CONTACT"]) {
		ContactViewController *contactViewController = [[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil];
		contactViewController.userID = self.userID;
		[self.navigationController pushViewController:contactViewController animated:YES];
		[contactViewController release];
	}
    [iFileName release];
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
    UIImageView *iview;
	UIImage *theImage = [[[UIImage alloc] initWithContentsOfFile:self.filePath] autorelease];
    NSLog(@"%@",self.filePath);
	if (theImage) {
        NSArray *subViews = [self.view subviews];
        if ([subViews count] > 1) {
            iview = [subViews objectAtIndex:0];
        } else {
            iview = [[[UIImageView alloc] initWithImage:theImage] autorelease];
        }
        iview.alpha = 0.3;
        CGRect frm = self.myTableView.frame;
        iview.frame = frm;
        if ([subViews count] == 1) {
            [self.view insertSubview:iview atIndex:0];
            //[iview release];
        }
        CGRect frame = self.myTableView.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        self.myTableView.frame = frame;            
        [self.view setNeedsDisplay];
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
    NSLog(@"mimeType = %@, status = %d",mimeType,status);
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
    [customActivityIndicator stopAnimating];
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
    int result;
    [self.menuFeedConnection release];
    self.menuFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    [customActivityIndicator stopAnimating];
    // NSLog(@"MenuViewController: finished loading data, starting to parse.");
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.menuData];
    [parser setDelegate:self];
    if (menuItems) {
        [menuItems release];
        menuItems = nil;
    }
    result = [parser parse];
    [currentStringValue release];
    currentStringValue = nil;
    [currentMenuItem release];
    currentMenuItem = nil;
#ifdef DEBUG
    NSLog(@"Parser returned %d",result);
#endif
    [parser release];
    [self.myTableView reloadData];
    [self initCache];
    
	NSString *fn = [self.imageFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"Set fn: %d",[self.imageFileName retainCount]);
    NSLog(@"%@",fn);
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
        [elementName isEqualToString:@"desc"] ||
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
        NSLog(@"%@",currentStringValue);
        currentMenuItem.fileName = currentStringValue;
    }
    if ([elementName isEqualToString:@"itemTitle"]) {
        currentMenuItem.itemTitle = currentStringValue;
    }
    if ([elementName isEqualToString:@"menuTitle"]) {
        self.menuTitle = currentStringValue;
    }
    if ([elementName isEqualToString:@"desc"]) {
        currentMenuItem.description = currentStringValue;
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
