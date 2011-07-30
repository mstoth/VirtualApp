//
//  ImagePageViewController.m
//  VirtualApp
//
//  Created by Michael Toth on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImagePageViewController.h"
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
    // Do any additional setup after loading the view from its nib.
    // fileName contains the path for the xml data
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonSystemItemAction target:self action:@selector(share:)];  
    
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
    url = [[NSURL alloc] initWithString:urlString];
    data = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];
    /*
    float ratio = image.size.height/image.size.width;
    CGRect frame = self.imageView.frame;
        frame.size.width = 320;
        frame.size.height = 320*ratio;
    self.imageView.frame = frame;
     */
    [self.imageView setImage:image];
    [image release];
    [data release];
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


@end
