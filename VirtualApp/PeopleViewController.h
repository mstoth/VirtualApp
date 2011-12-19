//
//  PeopleViewController.h
//  Symphony12
//
//  Created by Michael Toth on 12/16/10.
//  Copyright 2010 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLCacheConnection.h"
#import "MoreInfoViewController.h"
#import "Group.h"

@interface PeopleViewController : UIViewController <NSXMLParserDelegate, URLCacheConnectionDelegate, MoreInfoViewControllerDelegate> {
	NSString *webSite;  // path to directory of the xml file
    NSString *rootSite;
	NSString *fileName; // name of the xml file
	NSString *imageFileName; // name of the image file
	UIImage *myImage; 
	Group *group;
	// results from parsing the xml file go into these variables
	NSMutableArray *names;
	NSMutableArray *images;
	NSMutableArray *bios;
	NSMutableArray *mores;
	NSMutableString *currentStringValue;
	UIImageView *customActivityIndicator;
    
    NSURLConnection *groupFeedConnection;
    NSMutableData *groupData;
    NSOperationQueue *parseQueue;

	// URLCacheConnection variables
	NSString *dataPath;
	NSString *filePath;
	NSDate *fileDate;
	NSString *more;
	URLCacheConnection *connection;
	NSError *error;
	UIActivityIndicatorView *activityIndicator;
	
	// outlets
	UITextView *infoView;
	UIImageView *imageView;
	UITableView *tableView;
	UIButton *imageButton;
}
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) NSOperationQueue *parseQueue;
@property (nonatomic, retain) NSMutableData *groupData;
@property (nonatomic, retain) NSURLConnection *groupFeedConnection;

@property (nonatomic, retain) IBOutlet UITextView *infoView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIButton *imageButton;
@property (nonatomic, retain) NSString *webSite;
@property (nonatomic, retain) NSString *rootSite;
@property (nonatomic, retain) NSString *fileName;

-(void)initCache;
-(void)startAnimation;
-(void)stopAnimation;
- (void) displayImageWithURL:(NSURL *)theURL;
- (void) displayCachedImage;
-(void)getFileModificationDate;
- (IBAction)modalViewAction:(id)sender;
- (void)moreInfoViewControllerDidFinish:(MoreInfoViewController *)controller;
- (NSString *)myTitle;
-(IBAction)viewPicture:(id)sender;
- (void)groupError:(NSNotification *)notif;
- (void)handleError:(NSError *)theError;
-(void) setPaths:(NSString *)aweb root:(NSString *)aroot fileName:(NSString *)afileName;

@end
