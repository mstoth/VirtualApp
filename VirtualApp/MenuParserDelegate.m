//
//  MenuParserDelegate.m
//  VirtualApp
//
//  Created by Michael Toth on 4/9/11.
//  Copyright 2011 Michael Toth. All rights reserved.
//

#import "MenuParserDelegate.h"


@implementation MenuParserDelegate
@synthesize currentStringValue, currentMenuItem, menuItems, imageFileName, menuTitle;

-(id)init {
    [super init];
    accumulatingChars = NO;
    return self;
}

-(void) dealloc {
    [currentStringValue release];
    [self.menuTitle release];
    [self.imageFileName release];
    [super dealloc];
    [menuItems release];
    
}

#pragma mark -
#pragma mark NSXMLParser delegate routines

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"menu"]) {
        menuItems = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:@"menuItem"]) {
        currentMenuItem = [[MenuItem alloc] init];
    }
    if ([elementName isEqualToString:@"fileName"] ||
        [elementName isEqualToString:@"menuTitle"] ||
        [elementName isEqualToString:@"pageType"] ||
        [elementName isEqualToString:@"itemTitle"] ||
        [elementName isEqualToString:@"image"]) {
        accumulatingChars = YES;
        currentStringValue = [[NSMutableString alloc] init];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {   
    
    if ([elementName isEqualToString:@"menu"]) {
        [currentStringValue release];
        currentStringValue = nil;
        return;
    }
    if ([elementName isEqualToString:@"menuItem"]) {
        [self.menuItems addObject:currentMenuItem];
        [self.currentMenuItem release];
        currentMenuItem = nil;
    }
    if ([elementName isEqualToString:@"pageType"]) {
        self.currentMenuItem.pageType = currentStringValue;
    }
    if ([elementName isEqualToString:@"fileName"]) {
        self.currentMenuItem.fileName = currentStringValue;
    }
    if ([elementName isEqualToString:@"itemTitle"]) {
        self.currentMenuItem.itemTitle = currentStringValue;
    }
    if ([elementName isEqualToString:@"menuTitle"]) {
        self.menuTitle = currentStringValue;
    }
    if ([elementName isEqualToString:@"image"]) {
        self.imageFileName = currentStringValue;
    }
    accumulatingChars = NO;
    [currentStringValue release];
    currentStringValue = nil;    
}



- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingChars) {
        [currentStringValue appendString:string];
    }
}

@end
