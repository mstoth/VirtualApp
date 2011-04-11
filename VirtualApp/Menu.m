//
//  Menu.m
//  vapp2
//
//  Created by Michael Toth on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Menu.h"
#import "MenuItem.h"

@implementation Menu
@synthesize menuItems, title, fileName, userID, image;

- (id)init {
    //menuItems = [[NSMutableArray alloc] init];
    [super init];
    return self;
}
/*
- (void)addMenuItem:(MenuItem *)menuItem {
    [menuItems addObject:[[MenuItem alloc] initWithMenuItem:menuItem]];
    //[menuItems addObject:menuItem];
}
*/
-(void)dealloc {
	[menuItems release];
	[title release];
	[fileName release];
	[userID release];
	[image release];
	[super dealloc];
}

@end
