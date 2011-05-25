//
//  TextViewController.m
//  VirtualApp
//
//  Created by Michael Toth on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextViewController.h"


@implementation TextViewController
@synthesize textView, content, fileName;

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
    [self.content release];
    [self.fileName release];
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
#ifdef LOCAL
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://localhost:3000/%@",self.fileName];
#else
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://home.my-iphone-app.com/%@",self.fileName];
#endif
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSData *txtData = [[NSData alloc] initWithContentsOfURL:url];
     
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:txtData];
    [parser setDelegate:self];
    [parser parse];
    
    if ([self.content rangeOfString:@"<html"].location != NSNotFound) {
        webView = [[UIWebView alloc] initWithFrame:textView.frame];
#ifdef LOCAL
        [webView loadHTMLString:self.content baseURL:[[[NSURL alloc] initWithString:@"http://localhost:3000/"]autorelease]];
#else
        [webView loadHTMLString:self.content baseURL:[[[NSURL alloc] initWithString:@"http://home.my-iphone-app.com/"]autorelease]];
#endif
        [textView addSubview:webView];
        [webView release];
    } else {
        [textView setText:self.content];
    }
    
    [parser release];
    [url release];
    [urlString release];
    [txtData release];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"content"]) {
        accumulatingChars = YES;
        currentStringValue = [[NSMutableString alloc] init];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {   
    
    if ([elementName isEqualToString:@"content"]) {
        self.content = currentStringValue;
        NSLog(@"%@",currentStringValue);
        NSLog(@"%@",self.content);
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

@end
