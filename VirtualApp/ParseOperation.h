//
//  ParseOperation.h
//  vapp2
//
//  Created by Michael Toth on 3/28/11.
//  Copyright 2011 Michael Toth. All rights reserved.
//

//extern NSString *kAddSitesNotif;
//extern NSString *kSitesResultsKey;
//extern NSString *kSitesErrorNotif;
//extern NSString *kSitesMsgErrorKey;

#import "Menu.h"
#import "Menuitem.h"
#import "Group.h"
#import "GroupItem.h"
#import "MenuParserDelegate.h"

@class SiteObject;

@interface ParseOperation : NSOperation {
    NSData *sitesData, *menuData, *groupData;
	NSString *objectType;
@private

    // these variables are used during parsing
    SiteObject *currentSiteObject;
    MenuParserDelegate *mpd;
	Menu *currentMenu,*menu;
	MenuItem *currentMenuItem;
	Group *currentGroup;
	GroupItem *currentGroupItem;
    NSMutableArray *currentParseBatch;
    NSMutableString *currentParsedCharacterData;
    
    BOOL didAbortParsing;
}
@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@property (nonatomic, retain) GroupItem *currentGroupItem;
//@property (nonatomic, retain) Group *currentGroup;
@property (nonatomic, retain) Menu *currentMenu,*menu;
@property (nonatomic, retain) MenuItem *currentMenuItem;
@property (nonatomic, retain) NSString *objectType;
@property (copy, readonly) NSData *sitesData, *menuData, *groupData;

- (id)initWithDataAndType:(NSData *)parseData type:(NSString *)type;
@end
