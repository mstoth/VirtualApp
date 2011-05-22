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

@synthesize sitesData, menuData, groupData, currentSiteObject, currentMenuItem, currentMenu, menu, currentParsedCharacterData, currentParseBatch;
@synthesize objectType;
@synthesize currentGroup, currentGroupItem;

- (id)initwithData:(NSData *)parseData {
	if ((self = [super init])) {    
		sitesData = [parseData copy];
	}
    self.currentParsedCharacterData = nil;

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
            mpd = [[MenuParserDelegate alloc] init];
		}
	}
	if ([type isEqualToString:@"Group"]) {
		if ((self = [super init])) {
			groupData = [parseData copy];
		}
	}
	self.objectType = type;
    self.currentParsedCharacterData = nil;

    return self;
}

- (void)addGroup:(Group *)group {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddGroup" object:self 
                                                  userInfo:[NSDictionary dictionaryWithObject:group forKey:@"GroupResult"]];
}

- (void)addMenu:(Menu *)theMenu {
	assert([NSThread isMainThread]);
	// NSLog(@"ParseOperation:addMenu - Posting notification to AddMenus");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AddMenus" 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:theMenu
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
    //NSLog(@"Starting ParseOperation");
    self.menu = [[[Menu alloc] init] autorelease];
    //NSLog(@"self.menu:%d",[self.menu retainCount]);
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
        // NSLog(@"ParseOperation: Starting to parse.");
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.menuData];
		[parser setDelegate:mpd];
		[parser parse];
        // NSLog(@"mpd:%d",[mpd retainCount]);
        self.menu.menuItems = mpd.menuItems;
        self.menu.menuTitle = mpd.menuTitle;
        self.menu.image = mpd.imageFileName;
        self.menu.menutype = mpd.menutype;
        // NSLog(@"ParseOperation:main - self.menu retain count before performSelector... is %d",[self.menu retainCount]);
        [self performSelectorOnMainThread:@selector(addMenu:) withObject:self.menu waitUntilDone:NO];
        // NSLog(@"ParseOperation:main - self.menu retain count after performSelector... is %d",[self.menu retainCount]);
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
    // NSLog(@"self.menu:%d",[self.menu retainCount]);

    //[self.menu release];
    //self.menu=nil;

}

- (void)dealloc {
    if ([self.objectType isEqualToString:@"Group"]) {
        [groupData release];
        [self.menu release];
        [currentGroup release];
    }
	if ([self.objectType isEqualToString:@"Menu"]) {
        // NSLog(@"self.menu:%d",[self.menu retainCount]);
        [self.menu release];
        // NSLog(@"self.menu:%d",[self.menu retainCount]);

        self.menu=nil;
        // NSLog(@"ParseOperation:dealloc - mpd retain count is %d before release",[mpd retainCount]);
        [mpd release];
		[menuData release];
	}
	if ([self.objectType isEqualToString:@"App"]) {
        [self.menu release];
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
