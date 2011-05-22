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
@synthesize menuItems, menuTitle, fileName, userID, image, menutype;

- (id)init {
    [super init];
    menuItems = [[NSMutableArray alloc] init];
    return self;
}

- (id)initWithMenu:(Menu *)originalMenu {
    menuItems = originalMenu.menuItems;
    self.menuTitle = originalMenu.menuTitle;
    self.fileName = originalMenu.fileName;
    self.userID = originalMenu.userID;
    self.image = originalMenu.image;
    self.menutype = originalMenu.menutype;
    // NSLog(@"Menu:initWithMenu - self.menuItems retain count = %d",[self.menuItems retainCount]);
    [super init];
    return self;
}

-(void)dealloc {
    // NSLog(@"Menu:dealloc - self.menuItems retain count = %d",[self.menuItems retainCount]);
	[self.menuItems release];
	//[self.menuTitle release];
    //[self.menutype release];
	//[self.fileName release];
	//[self.userID release];
	//[self.image release];
    
    //self.menuItems = nil;
    //self.menuTitle = nil;
    //self.menutype = nil;
    //self.fileName = nil;
    //self.userID = nil;
    //self.image = nil;
    
	[super dealloc];
}

@end
