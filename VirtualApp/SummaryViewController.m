//
//  SummaryViewController.m
//  Symphony12
//
//  Created by Michael Toth on 12/15/10.
//  Copyright 2010 Michael Toth. All rights reserved.
//

#import "PayPal.h"
#import "PayPalPayment.h"
#import "PayPalAdvancedPayment.h"
#import "PayPalAmounts.h"
#import "PayPalReceiverAmounts.h"
#import "PayPalAddress.h"
#import "PayPalInvoiceItem.h"

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
@synthesize webSite, rootSite, fileName, purchase, blowup;
@synthesize buttonTextControl, imageView, notesView, infoView;
@synthesize imageButton, customButton;
@synthesize parseQueue, summaryData, summaryFeedConnection;
@synthesize buttonURL, buttonLabel;
@synthesize webView;

-(void) toggleNetworkIndicator {
	UIApplication *app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = !app.networkActivityIndicatorVisible;
}

- (void)viewDidLoad {
    if (!self.webSite || !self.rootSite || !self.fileName) {
        return;
    }
    [self initCache];
    NSString *urlString = [self.rootSite stringByAppendingPathComponent:fileName];
    
    // turn on activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // request profile data from the URL specified by webSite/fileName
    NSURLRequest *profileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
#ifdef DEBUG
    NSLog(@"URL for summary is %@",urlString);
#endif
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

- (void)setPaths:(NSString *)theweb root:(NSString *)theroot fileName:(NSString *)thefileName {
    self.webSite = theweb;
    self.rootSite = theroot;
    self.fileName = thefileName;
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
    productCompany = [[dict objectForKey:@"company"] retain];
    productDescription = [[dict objectForKey:@"description"] retain];
    productName = [[dict objectForKey:@"name"] retain];
    productRecipient = [[dict objectForKey:@"recipient"] retain];
    productShipping = [[dict objectForKey:@"shipping"] retain];
    productTax = [[dict objectForKey:@"tax"] retain];
    productPrice = [[dict objectForKey:@"price"] retain];
    
    more = [[NSString alloc] initWithString:[dict objectForKey:@"more"]];
    
    if ([infoView.text rangeOfString:@"<html"].location != NSNotFound) {
        self.webView = [[UIWebView alloc] initWithFrame:infoView.frame];
#ifdef LOCAL
        [self.webView loadHTMLString:infoView.text baseURL:[[[NSURL alloc] initWithString:@"http://localhost:3000/"]autorelease]];
#else
        [self.webView loadHTMLString:infoView.text baseURL:[[[NSURL alloc] initWithString:@"http://home.my-iphone-app.com/"]autorelease]];
#endif
        [self.view addSubview:self.webView];
        [self.webView release];
        self.webView = nil;
    }
    if ([notesView.text rangeOfString:@"<html"].location != NSNotFound) {
        self.webView = [[UIWebView alloc] initWithFrame:notesView.frame];
#ifdef LOCAL
        [self.webView loadHTMLString:notesView.text baseURL:[[[NSURL alloc] initWithString:@"http://localhost:3000/"]autorelease]];
#else
        [self.webView loadHTMLString:notesView.text baseURL:[[[NSURL alloc] initWithString:@"http://home.my-iphone-app.com/"]autorelease]];
#endif
        [self.view addSubview:self.webView];
        [self.webView release];
        self.webView = nil;
    }

    
    // display the image or load it and display it if it's not loaded yet. 
    NSString *fn = [imageFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *imageURL = [[NSURL alloc] initWithString:[self.rootSite  stringByAppendingPathComponent:fn]];
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
    } else {
        if (productRecipient.length > 0) {
            // Create Paypal buttons
            UIButton *button = [[PayPal getInstance] getPayButtonWithTarget:self andAction:@selector(payWithPayPal) andButtonType:BUTTON_152x33 andButtonText:BUTTON_TEXT_PAY];
            [button setFrame:CGRectMake(4,0,152,33)];
            [self.view addSubview:button];        
        } else {                        // no button defined, display label instead
            UILabel *label = [[UILabel alloc] init];
            label.text = @"Click on image to view.";
            label.numberOfLines = 1;
            label.adjustsFontSizeToFitWidth = true;
            label.frame = CGRectMake(4,0,152,33);
            [self.view addSubview:label];
            [label release];
        }
    }
    
    
	// Create a final modal view controller for viewing image full screen
    UIButton* modalViewButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [modalViewButton addTarget:self action:@selector(modalViewAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *modalBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:modalViewButton];
    self.navigationItem.rightBarButtonItem = modalBarButtonItem;
    [modalBarButtonItem release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark -
#pragma mark PayPal Callbacks

- (void) payWithPayPal {
	
	//optional, set shippingEnabled to TRUE if you want to display shipping
	//options to the user, default: TRUE
	[PayPal getInstance].shippingEnabled = TRUE;
	
	//optional, set dynamicAmountUpdateEnabled to TRUE if you want to compute
	//shipping and tax based on the user's address choice, default: FALSE
	[PayPal getInstance].dynamicAmountUpdateEnabled = TRUE;
	
	//optional, choose who pays the fee, default: FEEPAYER_EACHRECEIVER
	[PayPal getInstance].feePayer = FEEPAYER_EACHRECEIVER;
	
	//for a payment with a single recipient, use a PayPalPayment object
	PayPalPayment *payment = [[[PayPalPayment alloc] init] autorelease];
	payment.recipient = productRecipient;
	payment.paymentCurrency = @"USD";
	payment.description = productDescription;
	payment.merchantName = productCompany;
	
	//subtotal of all items, without tax and shipping
	payment.subTotal = [NSDecimalNumber decimalNumberWithString:productPrice];
	
	// invoiceData is a PayPalInvoiceData object which contains tax, shipping, and a list of PayPalInvoiceItem objects
	payment.invoiceData = [[[PayPalInvoiceData alloc] init] autorelease];
	payment.invoiceData.totalShipping = [NSDecimalNumber decimalNumberWithString:productShipping];
	payment.invoiceData.totalTax = [NSDecimalNumber decimalNumberWithString:productTax];
	
	// invoiceItems is a list of PayPalInvoiceItem objects
	//NOTE: sum of totalPrice for all items must equal payment.subTotal
	//NOTE: example only shows a single item, but you can have more than one
	payment.invoiceData.invoiceItems = [NSMutableArray array];
	PayPalInvoiceItem *item = [[[PayPalInvoiceItem alloc] init] autorelease];
    
	item.totalPrice = [NSDecimalNumber decimalNumberWithString:productPrice];
    item.itemPrice = [NSDecimalNumber decimalNumberWithString:productPrice];
	item.name = productName;
	[payment.invoiceData.invoiceItems addObject:item];
	
	[[PayPal getInstance] checkoutWithPayment:payment];
}

- (void) paymentFailedWithCorrelationID:(NSString *)correlationID andErrorCode:(NSString *)errorCode andErrorMessage:(NSString *)errorMessage {
}

- (void) paymentCanceled {
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"Payment Cancelled." message:@"You have cancelled the payment." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];
}

- (void) paymentLibraryExit {
    
}

- (void) paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Payment Succeeded" message:@"Thank you for your payment!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [av show];
    [av release];
}

- (PayPalAmounts *)adjustAmountsForAddress:(PayPalAddress const *)inAddress andCurrency:(NSString const *)inCurrency andAmount:(NSDecimalNumber const *)inAmount
									andTax:(NSDecimalNumber const *)inTax andShipping:(NSDecimalNumber const *)inShipping andErrorCode:(PayPalAmountErrorCode *)outErrorCode {
	//do any logic here that would adjust the amount based on the shipping address
	PayPalAmounts *newAmounts = [[[PayPalAmounts alloc] init] autorelease];
	newAmounts.currency = @"USD";
	newAmounts.payment_amount = (NSDecimalNumber *)inAmount;
	
	//change tax based on the address
    /*
     if ([inAddress.state isEqualToString:@"CA"]) {
     newAmounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[inAmount floatValue] * .1]];
     } else {
     newAmounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[inAmount floatValue] * .08]];
     }
     */
    newAmounts.tax = (NSDecimalNumber *)inTax; 
	newAmounts.shipping = (NSDecimalNumber *)inShipping;
	
	//if you need to notify the library of an error condition, do one of the following
	//*outErrorCode = AMOUNT_ERROR_SERVER;
	//*outErrorCode = AMOUNT_ERROR_OTHER;
	
	return newAmounts;
}

#pragma mark -
#pragma mark Memory Management

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
    self.buttonURL = nil;
    self.buttonLabel = nil;
    self.rootSite = nil;
}


- (void)dealloc {
    [self.summaryFeedConnection release];
    [self.summaryData release];
    [self.buttonURL release];
    [self.buttonLabel release];
    [parseQueue release];
    [filePath release];
    [self.webSite release];
    [self.fileName release];
	[more release];
    [self.rootSite release];
    [productCompany release];
    [productDescription release];
    [productName release];
    [productRecipient release];
    [productShipping release];
    [productTax release];
    [productPrice release];

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
    // for debugging purposes
//    NSUInteger status;
//    NSString *mimeType;
//    mimeType = [response MIMEType];
//    status = [httpResponse statusCode];
    if ((([httpResponse statusCode]/100) == 2) && ([[response MIMEType] isEqual:@"application/xml"] || [[response MIMEType] isEqual:@"text/xml"]) ) {
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
    [myConnection release];
    myConnection = nil;
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
	[myConnection release];
    myConnection = nil;
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
	webViewController.webSite = webSite;
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString release];
	webViewController.urlLocation = url;
	[self.navigationController pushViewController:webViewController animated:YES];
	[webViewController release];
}

@end
