//
//  ParseOperation.m
//  vapp2
//
//  Created by Michael Toth on 3/28/11.
//  Copyright 2011 Michael Toth. All rights reserved.
//


#import "ParseOperation.h"
#import "SiteObject.h"
#import "Menu.h"
#import "MenuItem.h"
#import "Group.h"
#import "GroupItem.h"
#import "SitesParserDelegate.h"
#import "GroupParserDelegate.h"
#import "MenuParserDelegate.h"

// NSNotification name for sending site data back to the app delegate
NSString *kAddSitesNotif = @"AddSitesNotif";

// NSNotification userInfo key for obtaining the site data
NSString *kSitesResultsKey = @"SitesResultsKey";

// NSNotification name for reporting errors
NSString *kSitesErrorNotif = @"SitesErrorNotif";

// NSNotification userInfo key for obtaining the error message
NSString *kSitesMsgErrorKey = @"SitesMsgErrorKey";


@interface ParseOperation () <NSXMLParserDelegate>
@property (nonatomic, retain) SiteObject *currentSiteObject;
@property (nonatomic, retain) Group *currentGroup;
//@property (nonatomic, retain) NSMutableArray *currentParseBatch;
//@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@end

@implementation ParseOperation

@synthesize sitesData, menuData, groupData, currentSiteObject, currentMenuItem, currentMenu, currentParsedCharacterData, currentParseBatch;
@synthesize objectType;
@synthesize currentGroup, currentGroupItem;

- (id)initwithData:(NSData *)parseData {
	if ((self = [super init])) {    
		sitesData = [parseData copy];
	}
	return self;
}


- (id)initWithDataAndType:(NSData *)parseData type:(NSString *)type 
{
	if ([type isEqualToString:@"App"]) {
		if ((self = [super init])) {    
			sitesData = [parseData copy];
		}
	}
	if ([type isEqualToString:@"Menu"]) {
		if ((self = [super init])) {
			menuData = [parseData copy];
		}
	}
	if ([type isEqualToString:@"Group"]) {
		if ((self = [super init])) {
			groupData = [parseData copy];
		}
	}
	self.objectType = type;
    return self;
}

- (void)addGroup:(Group *)group {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddGroup" object:self 
                                                  userInfo:[NSDictionary dictionaryWithObject:group forKey:@"GroupResult"]];
}

- (void)addMenu:(Menu *)menu {
	assert([NSThread isMainThread]);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AddMenus" 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:menu
                                                                                           forKey:@"menuResult"]];
	
}

- (void)addSitesToList:(NSArray *)sites {
    assert([NSThread isMainThread]);
    if(sites)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addSites"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:sites
                                                                                           forKey:@"sitesResult"]]; 
}

// the main function for this NSOperation, to start the parsing
- (void)main {
    
    self.currentParsedCharacterData = nil;
    
    
    if ([self.objectType isEqualToString:@"Group"]) {
        GroupParserDelegate *gpd = [[[GroupParserDelegate alloc] init] autorelease];
        
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:groupData];
        [parser setDelegate:gpd];
        [parser parse];
        
        Group *group = [[Group alloc] init];
        group.groupItems = gpd.groupItems;
        
        [self performSelectorOnMainThread:@selector(addGroup:) withObject:group waitUntilDone:NO];
        
        [group release];
        [parser release];
    }
    
	if ([self.objectType isEqualToString:@"Menu"]) {
        MenuParserDelegate *mpd = [[[MenuParserDelegate alloc] init] autorelease];
        
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.menuData];
		[parser setDelegate:mpd];
		[parser parse];
        
        Menu *menu = [[Menu alloc] init];
        menu.menuItems = mpd.menuItems;
        menu.title = mpd.menuTitle;
        menu.image = mpd.imageFileName;
        
        [self performSelectorOnMainThread:@selector(addMenu:) withObject:menu waitUntilDone:NO];
        
        [menu release];
        [parser release];
	}
	
    if ([self.objectType isEqualToString:@"App"]) {
        SitesParserDelegate *spd = [[[SitesParserDelegate alloc] init] autorelease];
        
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.sitesData];
		[parser setDelegate:spd];
		[parser parse];
		
        [self performSelectorOnMainThread:@selector(addSitesToList:) withObject:spd.siteObjects waitUntilDone:NO];
		[parser release];
	}
	
    
}

- (void)dealloc {
    if ([self.objectType isEqualToString:@"Group"]) {
        [groupData release];
        [currentGroup release];
    }
	if ([self.objectType isEqualToString:@"Menu"]) {
		[menuData release];
	}
	if ([self.objectType isEqualToString:@"App"]) {
		[sitesData release];
	}	
	[super dealloc];
    

}


// 
- (void)handleSitesError:(NSError *)parseError {
	[[NSNotificationCenter defaultCenter] postNotificationName:kSitesErrorNotif
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:parseError
																						   forKey:kSitesMsgErrorKey]];
}

//
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	if ([parseError code] != NSXMLParserDelegateAbortedParseError && !didAbortParsing)
	{
		[self performSelectorOnMainThread:@selector(handleSitesError:)
							   withObject:parseError
							waitUntilDone:NO];
	}
}

@end
