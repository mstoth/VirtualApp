//
//  GCalEventsViewController.h
//  VirtualApp
//
//  Created by Michael Toth on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalEvent.h"
#import "URLCacheConnection.h"
#import "CalTableViewCell.h"

#define FONT_SIZE 14.0f
#define TITLE_FONT_SIZE 18.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@interface GCalEventsViewController : UIViewController <NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *calEvents;
    CalEvent *currentEvent;
    NSURL *calURL;
    NSMutableData *calData;
    NSMutableString *currentStringValue;
    BOOL accumulatingChars;
    NSString *appID;
    NSInteger stage;
}
@property (nonatomic, retain) NSString *appID;
@property (nonatomic, retain) IBOutlet UITableView *eventTable;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSURLConnection *calConnection;
@property (nonatomic, retain) NSMutableData *calData;

- (void)handleError:(NSError *)theError;
//- (NSString *)userVisibleDateTimeStringForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString;

@end
