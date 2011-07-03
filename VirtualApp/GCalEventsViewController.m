//
//  GCalEventsViewController.m
//  VirtualApp
//
//  Created by Michael Toth on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GCalEventsViewController.h"
#import "CalEvent.h"
#import "URLCacheAlert.h"
#import "URLCacheConnection.h"
#import "CalAppParser.h"
#import "CalTableViewCell.h"

@implementation GCalEventsViewController

@synthesize eventTable, urlString, calData, calConnection, appID, filename;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{/*
    [self.eventTable release];
    self.eventTable = nil;
    [self.urlString release];
    self.urlString = nil;
    [self.calData release];
    self.calData = nil;
    [super dealloc];
    [self.appID release];
    self.appID = nil;*/
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
    stage = 1;
#ifdef LOCAL
    urlString = [[NSString alloc] initWithFormat:@"http://localhost:3000/%@",filename];
#else
    urlString = [[NSString alloc] initWithFormat:@"http://home.my-iphone-app.com/%@",filename];
#endif
#ifdef DEBUG
    NSLog(@"GCalEventsViewController: urlString is %@",urlString);
#endif
    calURL = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *menuRequest = [NSURLRequest requestWithURL:calURL];
    [calURL release];
    self.calConnection = [[NSURLConnection alloc] initWithRequest:menuRequest delegate:self];
    NSAssert(self.calConnection != nil, @"Failure to create URL connection for Calendar.");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [calEvents count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    CalEvent *item = [calEvents objectAtIndex:indexPath.row];
    CGSize constraint = CGSizeMake(320, 20000.0f);
    CGSize size = [item.content sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = 54+size.height;
#ifdef DEBUG
    NSLog(@"Cell %d height is %f",indexPath.row,height);
#endif
    return height;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CalCell";
    CalTableViewCell *cell;
    
    cell = (CalTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
#ifdef DEBUG
        NSLog(@"%@",@"Custom Cell Created.");
#endif
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"CalCustomCell" owner:nil options:nil];
        
        for (id currentObject in nibObjects) {
            if ([currentObject isKindOfClass:[CalTableViewCell class]])
            {
                cell = (CalTableViewCell *)currentObject;
            }
        }
        
    }
    CalEvent *item = [calEvents objectAtIndex:indexPath.row];
    [[cell content] setText:item.content];
    [[cell eventTitle] setText:item.title];
    [[cell eventTime] setText:[item start_time]];

    CGSize constraint = CGSizeMake(320, 20000.0f);
    CGSize size = [item.content sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    [[cell content] setFrame:CGRectMake(5, 36, 310, size.height+16)];

    [[cell viewForBackground] setFrame:CGRectMake(0, 0, size.width, 36+size.height)];
    [cell setFrame:CGRectMake(0, 0, size.width, 36+size.height)];
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
	[eventTable deselectRowAtIndexPath:indexPath animated:YES];
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
        self.calData = [NSMutableData data];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *theError = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:theError];
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
    [self.calConnection release];
    self.calConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.calData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    int result;
    [self.calConnection release];
    self.calConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
#ifdef DEBUG
    NSLog(@"GCalEventsViewController: finished loading data, starting to parse calendar.");
#endif
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.calData];
    [parser setDelegate:self];
    result = [parser parse];
    [parser release];
#ifdef DEBUG
    NSLog(@"Calendar Parser returned %d",result);
#endif
    [self.eventTable reloadData];
    self.calData = nil;
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

#pragma mark -
#pragma mark NSXMLParser delegate routines

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"cevents"]) {
        calEvents = [[NSMutableArray alloc] init];        
    }
    if ([elementName isEqualToString:@"cevent"]) {
        currentEvent = [[CalEvent  alloc] init];
    }
    if ([elementName isEqualToString:@"title"] ||
        [elementName isEqualToString:@"content"] ||
        [elementName isEqualToString:@"where"] ||
        [elementName isEqualToString:@"start-time"] ||
        [elementName isEqualToString:@"end-time"]) {
        accumulatingChars = YES;
        currentStringValue = [[NSMutableString alloc] init];        
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {   
    
    if ([elementName isEqualToString:@"cevent"]) {
        [calEvents addObject:currentEvent];
        [currentEvent release];
        currentEvent = nil;
    }
    if ([elementName isEqualToString:@"title"]) {
        currentEvent.title = currentStringValue;
    }
    if ([elementName isEqualToString:@"content"]) {
#ifdef DEBUG
        NSLog(@"Content = %@",currentStringValue);
#endif
        currentEvent.content = currentStringValue;
    }
    if ([elementName isEqualToString:@"start-time"]) {
        currentEvent.start_time = currentStringValue;
#ifdef DEBUG
        NSLog(@"start time = %@",currentEvent.start_time);
#endif
    }
    if ([elementName isEqualToString:@"end-time"]) {
        currentEvent.end_time = currentStringValue;
    }
    if ([elementName isEqualToString:@"where"]) {
        currentEvent.whereItIs = currentStringValue;
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
