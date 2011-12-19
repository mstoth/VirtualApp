//
//  ImagePageViewController.h
//  VirtualApp
//
//  Created by Michael Toth on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLCacheConnection.h"

@interface ImagePageViewController : UIViewController <NSXMLParserDelegate, URLCacheConnectionDelegate> {
    BOOL accumulatingChars;
    NSMutableString *currentStringValue;
    NSString *imageFileName;
    NSString *imageID;
    NSString *filePath;
    NSString *imageFileNameWithoutPath;
	NSString *dataPath;
	NSDate *fileDate;
	URLCacheConnection *myConnection;
	NSError *error;
	UIActivityIndicatorView *activityIndicator;
	UIImageView *customActivityIndicator;

}
@property (nonatomic, retain) NSString *imageFileName;
@property (nonatomic, retain) NSString *imageID;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
- (IBAction)share:(id)sender;
- (void) getFileModificationDate;
- (void) startAnimation;
- (void) stopAnimation;
- (void) displayImageWithURL:(NSURL *)theURL;
- (void) displayCachedImage;
- (void) initCache;
- (void) createCustomActivityIndicator;
@end
