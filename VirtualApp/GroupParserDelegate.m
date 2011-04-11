//
//  GroupParserDelegate.m
//  VirtualApp
//
//  Created by Michael Toth on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GroupParserDelegate.h"


@implementation GroupParserDelegate
@synthesize currentStringValue, currentGroupItem, groupItems, groupTitle;

-(id)init {
    [super init];
    accumulatingChars = NO;
    return self;
}

-(void) dealloc {
    [currentStringValue release];
    [groupTitle release];
    [super dealloc];
    [groupItems release];
}

#pragma mark -
#pragma mark NSXMLParser delegate routines

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"group"]) {
        groupItems = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:@"groupItem"]) {
        currentGroupItem = [[GroupItem alloc] init];
    }
    if ([elementName isEqualToString:@"info"] ||
        [elementName isEqualToString:@"more"] ||
        [elementName isEqualToString:@"name"] ||
        [elementName isEqualToString:@"image"]) {
        accumulatingChars = YES;
        currentStringValue = [[NSMutableString alloc] init];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {   
    
    if ([elementName isEqualToString:@"group"]) {
        [currentStringValue release];
        currentStringValue = nil;
        return;
    }
    if ([elementName isEqualToString:@"groupItem"]) {
        [groupItems addObject:currentGroupItem];
        [currentGroupItem release];
        currentGroupItem = nil;
        accumulatingChars = NO;
        [currentStringValue release];
        currentStringValue = nil;
    }
    if ([elementName isEqualToString:@"name"]) {
        currentGroupItem.name = currentStringValue;
        accumulatingChars = NO;
        [currentStringValue release];
        currentStringValue = nil;
    }
    if ([elementName isEqualToString:@"info"]) {
        currentGroupItem.info = currentStringValue;
        accumulatingChars = NO;
        [currentStringValue release];
        currentStringValue = nil;
    }
    if ([elementName isEqualToString:@"image"]) {
        currentGroupItem.image = currentStringValue;
        accumulatingChars = NO;
        [currentStringValue release];
        currentStringValue = nil;
    }
    if ([elementName isEqualToString:@"more"]) {
        currentGroupItem.more = currentStringValue;
        accumulatingChars = NO;
        [currentStringValue release];
        currentStringValue = nil;
    }
    
}



- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingChars) {
        [currentStringValue appendString:string];
    }
}

@end
