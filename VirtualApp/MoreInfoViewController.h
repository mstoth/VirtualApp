//
//  MoreInfoViewController.h
//  Symphony12
//
//  Created by Michael Toth on 12/15/10.
//  Copyright 2010 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MoreInfoViewControllerDelegate;


@interface MoreInfoViewController : UIViewController {
	id <MoreInfoViewControllerDelegate> delegate;
	UITextView *textView;
	NSString *moreInfo;
	UINavigationBar *navBar;
}

@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) NSString *moreInfo;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, assign) id <MoreInfoViewControllerDelegate> delegate;
- (IBAction)done:(id)sender;
@end

@protocol MoreInfoViewControllerDelegate
- (NSString *)myTitle;
- (void)moreInfoViewControllerDidFinish:(MoreInfoViewController *)controller;
@end
