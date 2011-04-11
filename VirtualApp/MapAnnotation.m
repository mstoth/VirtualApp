//
//  MapAnnotation.m
//  vapp2
//
//  Created by Michael Toth on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapAnnotation.h"


@implementation MapAnnotation
@synthesize coordinate, title, subtitle;

- (id) initWithCoordinate: (CLLocationCoordinate2D) aCoordinate {
	if (self = [super init]) coordinate = aCoordinate;
	return self;
}

- (void) dealloc {
	self.title = nil;
	self.subtitle = nil;
	[super dealloc];
}

@end
