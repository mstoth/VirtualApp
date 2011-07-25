//
//  MenuViewController.h
//  Symphony12
//
//  Created by Michael Toth on 12/14/10.
//  Copyright 2010 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLCacheConnection.h"
#import "Menu.h"
#import "MenuItem.h"
#define FONT_SIZE 14.0f
#define TITLE_FONT_SIZE 18.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
@interface MenuViewController : UIViewController  <NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource, URLCacheConnectionDelegate> {
	
	NSMutableString *currentStringValue; // used by parser to keep intermediate results
	Menu *menu;
    NSString *rootSite; // path to the root of public directory
	NSString *webSite;  // path to directory of the xml file
	NSString *fileName; // name of the xml file
	UITableView *myTableView;
    NSString *description;
    
    // parser variables
    NSMutableArray *menuItems;
    MenuItem *currentMenuItem;
	BOOL accumulatingChars;
    
	// results from parsing the xml file go into these variables
	NSString *menuTitle;
	NSString *imageFileName;
	NSMutableArray *pageTypes;
	NSMutableArray *fileNames;
	NSString *userID;
    NSString *appID;
	
	// URLCacheConnection variables
	NSString *dataPath;
	NSString *filePath;
	NSDate *fileDate;
	NSURLConnection *connection;
	NSError *error;
	UIActivityIndicatorView *activityIndicator;
	
    NSURLConnection *menuFeedConnection;
    NSMutableData *menuData;
    UITableViewCell *cellView;
    UIImageView *customActivityIndicator;
    UIImageView *banner;
	
}
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) Menu *menu;
@property (nonatomic, retain) NSURLConnection *menuFeedConnection;
@property (nonatomic, retain) NSMutableData *menuData;
@property (nonatomic, retain) IBOutlet UITableViewCell *cellView;

@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *appID;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSString *menuTitle;
@property (nonatomic, retain) NSMutableArray *pageTypes;
@property (nonatomic, retain) NSMutableArray *fileNames;
@property (nonatomic, retain) NSString *rootSite;
@property (nonatomic, retain) NSString *webSite;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *menuType;
@property (nonatomic, retain) NSString *imageFileName;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *dataPath;
@property (nonatomic, retain) IBOutlet UIImageView *banner;
-(void)initCache;
-(void)startAnimation;
-(void)stopAnimation;
- (void) displayImageWithURL:(NSURL *)theURL;
- (void) displayCachedImage;
-(void)getFileModificationDate;
- (BOOL)hidesBottomBarWhenPushed;
- (void)handleError:(NSError *)theError;
- (void)setPaths:(NSString *)web root:(NSString *)root fname:(NSString *)fname;
@end
