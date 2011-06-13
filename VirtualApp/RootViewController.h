//
//  RootViewController.h
//  VirtualApp
//
//  Created by Michael Toth on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "/usr/include/sqlite3.h"
#import "MenuViewController.h"
#include "SiteObject.h"

//#define kSitesURL @"http://iapp.vsec.railsplayground.net/apps/listapps"
#ifdef LOCAL
#define kSitesURL @"http://localhost:3000/apps/listapps"
#else
#define kSitesURL @"http://home.my-iphone-app.com/apps/listapps"
#endif
#define kAddSitesNotif @"addSites"
#define kSitesErrorNotif @"sitesError"
#define kSitesMsgErrorKey @"msgError"
#define kFilename @"bookmarks.sqlite3"
#define alphabet @"abcdefghijklmnopqrstuvwxyz"

typedef enum {
	ALL,
	BOOKMARKS,
	CATEGORIES,
    GROUPS,
	SUBLIST
} DisplayMode; 

@interface RootViewController : UIViewController <NSXMLParserDelegate> {
	NSMutableArray *subList;
	NSString *currentCategory;
	NSMutableArray *categoryList;
    UITableView *tableView;
    
@private
	NSURLConnection *sitesFeedConnection;
	NSMutableData *sitesData;
	NSOperationQueue *parseQueue;
    NSString *defaultAppID;
    NSString *defaultUserID;
    MenuViewController  *defaultMenuViewController;
    NSString *urlString;
    
    NSMutableArray *siteObjects;
    NSMutableArray *copyOfSiteObjects;
    SiteObject *currentSite;
    NSMutableString *currentStringValue;
    BOOL accumulatingChars;
    
	sqlite3 *database;
	
	UIToolbar *toolBar;
	UIBarButtonItem *allButtonItem, *bookmarksButtonItem, *categoriesButtonItem;
	DisplayMode displayMode;
}
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *currentCategory; 
@property (nonatomic, retain) NSMutableArray *categoryList,*subList;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *allButtonItem, *bookmarksButtonItem, *categoriesButtonItem;
@property (nonatomic, retain) NSOperationQueue *parseQueue;
@property (nonatomic, retain) NSMutableData *sitesData;

@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;

- (void) handleError:(NSError *)error;
- (void) loadSites;
- (void) copySites;
- (void) resetSearch;
- (void) handleSearchForTerm:(NSString *)searchTerm; 

- (IBAction) allButtonItemPushed:(id)sender;
- (IBAction) bookmarksButtonItemPushed:(id)sender;
- (IBAction) categoriesButtonItemPushed:(id)sender;

@end
