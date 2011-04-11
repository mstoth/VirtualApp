//
//  ProfileParserDelegate.m
//  vapp2
//
//  Created by Michael Toth on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileParserDelegate.h"


@implementation ProfileParserDelegate
@synthesize userName, street, cityStateZip, phone, email, longitude, latitude; 
#pragma mark -
#pragma mark XML Parser

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
	if (!currentStringValue) {
		currentStringValue=[[NSMutableString alloc] initWithString:@""];
	}
	if ([elementName isEqualToString:@"name"]) {
		self.userName = [[NSString alloc] initWithString:currentStringValue];
	}
	if ([elementName isEqualToString:@"street"]) {
		self.street = [[NSString alloc] initWithString:currentStringValue];
	}
	if ([elementName isEqualToString:@"citystatezip"]) {
		self.cityStateZip = [[NSString alloc] initWithString:currentStringValue];
	}
	if ([elementName isEqualToString:@"phone"]) {
		self.phone = [[NSString alloc] initWithString:currentStringValue];
	}
	if ([elementName isEqualToString:@"email"]) {
		self.email = [[NSString alloc] initWithString:currentStringValue];
	}
	if ([elementName isEqualToString:@"latitude"]) {
		self.latitude = [[NSString alloc] initWithString:currentStringValue];
	}
	if ([elementName isEqualToString:@"longitude"]) {
		self.longitude = [[NSString alloc] initWithString:currentStringValue];
	}
	[currentStringValue release];
	currentStringValue = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentStringValue) {
        // currentStringValue is an NSMutableString instance variable
        currentStringValue = [[NSMutableString alloc] initWithString:string];
    } else {
		[currentStringValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if (currentStringValue) {
		[currentStringValue release];
	}
	currentStringValue = nil;
}

@end
