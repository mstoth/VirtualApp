//
//  WebViewController.h
//  Symphony12
//
//  Created by Michael Toth on 12/17/10.
//  Copyright 2010 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController {
	UIWebView *webView;
	NSString *fileName;
	NSString *webSite;
	NSURL *urlLocation;
	
}
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *webSite;
@property (nonatomic, retain) NSURL *urlLocation;
@end
