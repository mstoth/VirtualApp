//
//  SitesParserDelegate.m
//  VirtualApp
//
//  Created by Michael Toth on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SitesParserDelegate.h"


@implementation SitesParserDelegate
@synthesize currentStringValue, currentSite, siteObjects;

-(id)init {
    [super init];
    accumulatingChars = NO;
    return self;
}

-(void)dealloc {
    [siteObjects release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSXMLParser delegate routines

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"apps"]) {
        siteObjects = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:@"app"]) {
        currentSite = [[SiteObject alloc] init];
    }
    if ([elementName isEqualToString:@"category"] ||
        [elementName isEqualToString:@"id"] ||
        [elementName isEqualToString:@"title"] ||
        [elementName isEqualToString:@"icon-file-name"] ||
        [elementName isEqualToString:@"user-id"]) {
        accumulatingChars = YES;
        currentStringValue = [[NSMutableString alloc] init];
    }
        
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {   
    
    if ([elementName isEqualToString:@"app"]) {
        [siteObjects addObject:currentSite];
        [currentStringValue release];
        currentStringValue = nil;
        [currentSite release];
        currentSite = nil;
    }
    if ([elementName isEqualToString:@"category"]) {
        currentSite.category = currentStringValue;
        accumulatingChars = NO;
        [currentStringValue release];
        currentStringValue = nil;
    }
    if ([elementName isEqualToString:@"id"]) {
        currentSite.appID = currentStringValue;
        accumulatingChars = NO;
        [currentStringValue release];
        currentStringValue = nil;
    }
    if ([elementName isEqualToString:@"title"]) {
        currentSite.siteTitle = currentStringValue;
        accumulatingChars = NO;
        [currentStringValue release];
        currentStringValue = nil;
    }
    if ([elementName isEqualToString:@"icon-file-name"]) {
        currentSite.filename = currentStringValue;
        accumulatingChars = NO;
        [currentStringValue release];
        currentStringValue = nil;
    }
    if ([elementName isEqualToString:@"user-id"]) {
        currentSite.userID = currentStringValue;
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
