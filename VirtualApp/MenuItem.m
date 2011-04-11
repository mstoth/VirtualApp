//
//  MenuItem.m
//  vapp2
//
//  Created by Michael Toth on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuItem.h"


@implementation MenuItem
@synthesize itemTitle, fileName, pageType;

- (id)initWithMenuItem:(MenuItem *)menuItem {
    [super init];
    self.itemTitle = menuItem.itemTitle;
    self.fileName = menuItem.fileName;
    self.pageType = menuItem.pageType;
    return self;
}

- (void)dealloc {
	[itemTitle release];
	[fileName release];
	[pageType release];
	[super dealloc];
}

@end
