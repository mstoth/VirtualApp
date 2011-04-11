//
//  Menu.h
//  vapp2
//
//  Created by Michael Toth on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuItem.h"

@interface Menu : NSObject {
	NSMutableArray *menuItems;
	NSString *fileName; 
	NSString *title; 
	NSString *userID;
	NSString *image;
}
@property (nonatomic, retain) NSMutableArray *menuItems;
@property (nonatomic, retain) NSString *fileName, *title, *userID, *image; 
//- (void) addMenuItem:(MenuItem *)menuItem;

@end
