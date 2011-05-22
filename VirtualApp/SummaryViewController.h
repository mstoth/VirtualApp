//
//  SummaryViewController.h
//  Symphony12
//
//  Created by Michael Toth on 12/15/10.
//  Copyright 2010 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLCacheConnection.h"
#import "MoreInfoViewController.h"
#import "ListChoiceViewController.h"



@interface SummaryViewController : UIViewController < /*PayPalPaymentDelegate,*/   URLCacheConnectionDelegate, MoreInfoViewControllerDelegate> {
	NSMutableString *currentStringValue; // used by parser to keep intermediate results
	NSString *userID;
	NSString *webSite;  // path to directory of the xml file
    NSString *rootSite; // path to the root web site
	NSString *fileName; // name of the xml file
	
	// results from parsing the xml file go into these variables
	NSString *menuTitle;
    NSString *imageFileNameWithoutPath;
	NSString *imageFileName;
	NSString *info;
	NSString *notes;
	NSString *more;
	NSString *recipient;
	NSString *productID;
	NSString *buttonURL;
	NSString *buttonLabel;
    
    NSURLConnection *summaryFeedConnection;
    NSMutableData *summaryData;
    NSOperationQueue *parseQueue;

	UISegmentedControl *buttonTextControl;

	// URLCacheConnection variables
	NSString *dataPath;
	NSString *filePath;
	NSDate *fileDate;
	NSURLConnection *myConnection;
	NSError *error;
	UIActivityIndicatorView *activityIndicator;
	UIButton *customButton;
	
	// Outlets
	UIImageView *imageView;
	UITextView *notesView;
	UITextView *infoView;
	
}
@property (nonatomic, retain) NSString *buttonLabel;
@property (nonatomic, retain) NSString *buttonURL;
@property (nonatomic, retain) NSOperationQueue *parseQueue;
@property (nonatomic, retain) NSMutableData *summaryData;
@property (nonatomic, retain) NSURLConnection *summaryFeedConnection;

@property (nonatomic, retain) IBOutlet UIButton *customButton;
@property (nonatomic, retain) IBOutlet UIButton *imageButton;
@property (nonatomic, retain) IBOutlet UIButton	*blowup;

@property (nonatomic, retain) NSString *rootSite;
@property (nonatomic, retain) NSString *webSite;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *fileName;

@property (nonatomic, retain) IBOutlet UIButton *purchase;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UITextView *notesView;
@property (nonatomic, retain) IBOutlet UITextView *infoView;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) UISegmentedControl *buttonTextControl;

-(void)startAnimation;
-(void)stopAnimation;
-(void)displayCachedImage;
-(void)getFileModificationDate;
-(void)initCache;
-(void)displayImageWithURL:(NSURL *)theURL;
-(NSString *)myTitle;
- (IBAction)modalViewAction:(id)sender;
- (IBAction)makePurchase:(id)sender;
- (IBAction)blowupImage:(id)sender;
- (void)moreInfoViewControllerDidFinish:(MoreInfoViewController *)controller;
- (void)buttonPressed;
- (void)handleError:(NSError *)error;
- (void)setPaths:(NSString *)web root:(NSString *)root fileName:(NSString *)fileName;
@end
