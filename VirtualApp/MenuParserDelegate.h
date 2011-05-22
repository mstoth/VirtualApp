//
//  MenuParserDelegate.h
//  VirtualApp
//
//  Created by Michael Toth on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Menu.h"
#import "MenuItem.h"

@interface MenuParserDelegate : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentStringValue;
    MenuItem *currentMenuItem;
    NSMutableArray *menuItems;
    BOOL accumulatingChars;
    NSString *menutype, *menuTitle, *imageFileName;

}
//@property (nonatomic, retain) NSMutableString *currentStringValue;
//@property (nonatomic, retain) MenuItem *currentMenuItem;
@property (nonatomic, retain) NSMutableArray *menuItems;
@property (nonatomic, retain) NSString *menutype, *menuTitle, *imageFileName;

@end
