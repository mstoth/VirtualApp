//
//  CalAppParser.m
//  VirtualApp
//
//  Created by Michael Toth on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalAppParser.h"


@implementation CalAppParser 
@synthesize username, title, password;

#pragma mark -
#pragma mark NSXMLParser delegate routines

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"title"] ||
        [elementName isEqualToString:@"username"] ||
        [elementName isEqualToString:@"password"]) {
        accumulatingChars = YES;
        currentStringValue = [[NSMutableString alloc] init];        
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {   
    
    if ([elementName isEqualToString:@"title"]) {
        self.title = currentStringValue;
    }
    if ([elementName isEqualToString:@"username"]) {
        self.username = currentStringValue;
    }
    if ([elementName isEqualToString:@"password"]) {
        self.password = currentStringValue;
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
