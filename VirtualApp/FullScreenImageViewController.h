//
//  FullScreenImageViewController.h
//  Symphony12
//
//  Created by Michael Toth on 12/18/10.
//  Copyright 2010 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FullScreenImageViewController : UIViewController {
	UIImageView *imageView;
	UIButton *imageButton;
	UIImage *myImage;
}
@property (nonatomic, retain) UIImage *myImage;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *imageButton;
-(IBAction)done:(id)sender;
@end
