//
//  ContactViewController.m
//  vapp2
//
//  Created by Michael Toth on 3/17/11.
//  Copyright 2011 Michael Toth. All rights reserved.
//

#import "ContactViewController.h"
#import "ProfileParserDelegate.h"
#import "MapAnnotation.h"
#import "GeneralParser.h"
#import "ParseOperation.h"

@implementation ContactViewController
@synthesize userName, street, street2, cityStateZip, city, state, zip, phone, email, mapView;
@synthesize userID, appID;
@synthesize parseQueue, profileData, profileFeedConnection;

-(void) toggleNetworkIndicator {
	UIApplication *app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = !app.networkActivityIndicatorVisible;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//int success;
	if (userID>0) {
        
#ifdef LOCAL
        NSString *urlStringFormat = @"http://localhost:3000/users/%@/showprofile";
#else
        NSString *urlStringFormat = @"http://home.my-iphone-app.com/users/%@/showprofile";
#endif
        
		NSString *urlString = [[NSString alloc] initWithFormat:urlStringFormat, self.userID];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

        NSURLRequest *profileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        self.profileFeedConnection = [[[NSURLConnection alloc] initWithRequest:profileRequest delegate:self] autorelease];
        
        NSOperationQueue * theQueue = [[NSOperationQueue alloc] init];
        self.parseQueue = theQueue;
        [theQueue release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(parserDone:)
                                                     name:@"parserDone"
                                                   object:nil];
        
        
        [urlString release];
        
    } 
    [super viewDidLoad];
}


- (void)parserDone:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    NSDictionary *dict = [notif userInfo];
    NSString *value;
    value = [dict objectForKey:@"name"];
    userName.text = value;
    value = [dict objectForKey:@"street1"];
    street.text = value;
    value = [dict objectForKey:@"street2"];
    street2.text = value;
    cityStateZip.text = [dict objectForKey:@"citystatezip"];
    city.text = [dict objectForKey:@"city"];
    state.text = [dict objectForKey:@"state"];
    zip.text = [dict objectForKey:@"zip"];
    phone.text = [dict objectForKey:@"phone"];
    email.text = [dict objectForKey:@"email"];
    latitude = [[dict objectForKey:@"latitude"] floatValue];
    longitude = [[dict objectForKey:@"longitude"] floatValue];
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = latitude ;
    newRegion.center.longitude = longitude;
    newRegion.span.latitudeDelta = 0.0125;
    newRegion.span.longitudeDelta = 0.0125;
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = latitude;
    coordinate.longitude = longitude;
    
    MapAnnotation *anAnnotation = [[[MapAnnotation alloc] initWithCoordinate:coordinate] autorelease];
    [self.mapView addAnnotation:anAnnotation];
    [self.mapView setRegion:newRegion animated:NO];

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
    self.userName = nil;
    self.street = nil;
    self.street2 = nil;
    self.city = nil;
    self.state = nil;
    self.zip = nil;
    self.cityStateZip = nil;
    self.phone = nil;
    self.userID = nil;
    self.appID = nil;
    self.mapView = nil;
    self.parseQueue = nil;
    self.profileData = nil;
    [super viewDidUnload];
}


- (void)dealloc {
    [parseQueue release]; 
    [userName release];
    [street release];
    [street2 release];
    [cityStateZip release];
    [city release];
    [state release];
    [zip release];
    [phone release];
    [userID release];
    [appID release];
    [profileData release];
    [mapView release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // check for HTTP status code for proxy authentication failures
    // anything in the 200 to 299 range is considered successful,
    // also make sure the MIMEType is correct:
    //
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
#ifdef DEBUG
    NSUInteger status;
    NSString *mimeType;
    mimeType = [response MIMEType];
    status = [httpResponse statusCode];
    NSLog(@"MIME type is %@ and status code is %d",mimeType,status);
#endif
    if ((([httpResponse statusCode]/100) == 2) && ([[response MIMEType] isEqual:@"application/xml"] || [[response MIMEType] isEqual:@"text/xml"]) ) {
        self.profileData = [[NSMutableData alloc] init];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
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
    self.profileFeedConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.profileData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.profileFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    GeneralParser *parseOperation = [[GeneralParser alloc] initWithData:profileData];
    [self.parseQueue addOperation:parseOperation];
    [parseOperation release];   
    [profileData release];
    self.profileData = nil;
}

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
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

@end
