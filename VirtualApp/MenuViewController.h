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
@interface MenuViewController : UIViewController  <URLCacheConnectionDelegate> {
	
	NSMutableString *currentStringValue; // used by parser to keep intermediate results
	Menu *menu;
	NSString *webSite;  // path to directory of the xml file
	NSString *fileName; // name of the xml file
	UITableView *myTableView;
	
	// results from parsing the xml file go into these variables
	NSString *menuTitle;
	NSString *imageFileName;
	NSMutableArray *menuItems;
	NSMutableArray *pageTypes;
	NSMutableArray *fileNames;
	NSString *userID;
	
	// URLCacheConnection variables
	NSString *dataPath;
	NSString *filePath;
	NSDate *fileDate;
	NSURLConnection *connection;
	NSError *error;
	UIActivityIndicatorView *activityIndicator;
	
    NSURLConnection *menuFeedConnection;
    NSMutableData *menuData;
    NSOperationQueue *parseQueue;
	
}
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) Menu *menu;
@property (nonatomic, retain) NSURLConnection *menuFeedConnection;
@property (nonatomic, retain) NSMutableData *menuData;
@property (nonatomic, retain) NSOperationQueue *parseQueue;

@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSString *menuTitle;
@property (nonatomic, retain) NSMutableArray *menuItems;
@property (nonatomic, retain) NSMutableArray *pageTypes;
@property (nonatomic, retain) NSMutableArray *fileNames;
@property (nonatomic, retain) NSString *webSite;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *dataPath;
-(void)initCache;
-(void)startAnimation;
-(void)stopAnimation;
- (void) displayImageWithURL:(NSURL *)theURL;
- (void) displayCachedImage;
-(void)getFileModificationDate;
- (BOOL)hidesBottomBarWhenPushed;
- (void)handleError:(NSError *)theError;
@end
