//
//  GeneralParser.m
//  VirtualApp
//
//  Created by Michael Toth on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GeneralParser.h"

@interface GeneralParser () <NSXMLParserDelegate>
@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@end


@implementation GeneralParser
@synthesize parsedData, dataIn, currentParseBatch, currentParsedCharacterData;

- (id)initWithData:(NSData *)data {
    self = [super init];
    dataIn = [data copy];
    return self;
}

- (void)dealloc {
    [parsedData removeAllObjects];
    [parsedData release];
    parsedData = nil;
    [dataIn release];
    [super dealloc];
}

- (void)main {
    if (self.parsedData) {
        [self.parsedData release];
        self.parsedData = nil;
    }
    currentParseBatch = [NSMutableArray array];
    currentParsedCharacterData = [NSMutableString string];
    firstElementName = nil;
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.dataIn];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
    if (!firstElementName) {
        firstElementName = [[NSString alloc] initWithString:elementName];
    }
    accumulatingParsedCharacterData = YES;
    [currentParsedCharacterData setString:@""];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {   
    
    NSString *value = [[NSString alloc] initWithString:currentParsedCharacterData];
    [currentParsedCharacterData setString:@""];

#ifdef DEBUG
    NSLog(@"Adding %@ and %@ to dictionary.",value,elementName);
#endif
    if (!parsedData) {
        self.parsedData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:value, elementName, nil];
    } else {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:value,elementName, nil];
        [self.parsedData addEntriesFromDictionary:dict];
        [dict release];
    }
    [value release];
    if ([elementName isEqualToString:firstElementName]) {
        // indicate done
        
        [self performSelectorOnMainThread:@selector(parserDone:)
                               withObject:self.parsedData
                            waitUntilDone:NO];
        [firstElementName release];
        firstElementName = nil;

    }
	// Stop accumulating parsed character data. We won't start again until specific elements begin.
	accumulatingParsedCharacterData = NO;
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element.
// The parser is not guaranteed to deliver all of the parsed character data for an element in a single
// invocation, so it is necessary to accumulate character data until the end of the element is reached.
//
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (accumulatingParsedCharacterData) {
		// If the current element is one whose content we care about, append 'string'
		// to the property that holds the content of the current element.
		//
		[currentParsedCharacterData appendString:string];
	}
}

- (void) parserDone:(NSNotification *)dict {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"parserDone" object:self userInfo:self.parsedData];
    [self.parsedData release];
}
// an error occurred while parsing the earthquake data,
// post the error as an NSNotification to our app delegate.
// 
- (void)handleSitesError:(NSError *)parseError {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ParserError"
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:parseError
																						   forKey:@"ParseError" ]];
}

// an error occurred while parsing the earthquake data,
// pass the error to the main thread for handling.
// (note: don't report an error if we aborted the parse due to a max limit of earthquakes)
//
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	if ([parseError code] != NSXMLParserDelegateAbortedParseError && !didAbortParsing)
	{
		[self performSelectorOnMainThread:@selector(handleSitesError:)
							   withObject:parseError
							waitUntilDone:NO];
	}
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
