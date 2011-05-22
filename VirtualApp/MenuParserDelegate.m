//
//  MenuParserDelegate.m
//  VirtualApp
//
//  Created by Michael Toth on 4/9/11.
//  Copyright 2011 Michael Toth. All rights reserved.
//

#import "MenuParserDelegate.h"


@implementation MenuParserDelegate
@synthesize    menutype, menuItems, imageFileName, menuTitle;

-(id)init {
    [super init];
    accumulatingChars = NO;
    return self;
}

-(void) dealloc {
    /*
    [self.menuTitle release];
    [self.imageFileName release];*/
    // NSLog(@"MenuParserDelegate:dealloc - menuItems retain count is %d",[self.menuItems retainCount]);
    //[self.menuItems release];
    //[self.menutype release];
    [currentMenuItem release];
    currentMenuItem = nil;
    [currentStringValue release];
    currentStringValue = nil;
    /*self.menuTitle = nil;
    self.imageFileName = nil;
    self.menuItems = nil;
    self.menutype = nil;*/
    [super dealloc];
}

#pragma mark -
#pragma mark NSXMLParser delegate routines

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"menu"]) {
        menuItems = [[NSMutableArray alloc] init];
        // NSLog(@"menuItems retain count after init is %d",[self.menuItems retainCount]);

    }
    if ([elementName isEqualToString:@"menuItem"]) {
        currentMenuItem = [[MenuItem alloc] init];
    }
    if ([elementName isEqualToString:@"fileName"] ||
        [elementName isEqualToString:@"menuTitle"] ||
        [elementName isEqualToString:@"pageType"] ||
        [elementName isEqualToString:@"itemTitle"] ||
        [elementName isEqualToString:@"menutype"] ||
        [elementName isEqualToString:@"image"]) {
        accumulatingChars = YES;
        currentStringValue = [[NSMutableString alloc] init];
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
        currentMenuItem.fileName = currentStringValue;
    }
    if ([elementName isEqualToString:@"itemTitle"]) {
        currentMenuItem.itemTitle = currentStringValue;
    }
    if ([elementName isEqualToString:@"menuTitle"]) {
        self.menuTitle = currentStringValue;
    }
    if ([elementName isEqualToString:@"menutype"]) {
        self.menutype = currentStringValue;
    }
    if ([elementName isEqualToString:@"image"]) {
        self.imageFileName = currentStringValue;
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
