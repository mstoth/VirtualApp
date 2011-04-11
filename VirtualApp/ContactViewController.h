//
//  ContactViewController.h
//  vapp2
//
//  Created by Michael Toth on 3/17/11.
//  Copyright 2011 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface ContactViewController : UIViewController {
	UILabel *userName;
	UILabel *street;
	UILabel *cityStateZip;
	UITextView *phone, *email;
	NSString *userID, *appID;
	MKMapView *mapView;
	double latitude, longitude;
	NSMutableString *currentStringValue;
    NSURLConnection *profileFeedConnection;
    NSMutableData *profileData;
    NSOperationQueue *parseQueue;


}
@property (nonatomic, retain) NSOperationQueue *parseQueue;
@property (nonatomic, retain) NSMutableData *profileData;
@property (nonatomic, retain) NSURLConnection *profileFeedConnection;

@property (nonatomic, retain) NSString *userID, *appID;
@property (nonatomic, retain) IBOutlet UITextView *phone, *email; 
@property (nonatomic, retain) IBOutlet UILabel *userName, *street, *cityStateZip;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
- (void)handleError:(NSError *)error ;
- (void)parserDone:(NSNotification *)notif;
@end
