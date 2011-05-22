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
	NSString *menuTitle; 
    NSString *menutype;
	NSString *userID;
	NSString *image;
}
@property (nonatomic, retain) NSMutableArray *menuItems;
@property (nonatomic, retain) NSString *fileName, *menuTitle, *userID, *image, *menutype; 
//- (void) addMenuItem:(MenuItem *)menuItem;
- (id) initWithMenu:(Menu *)menu;
@end
