//
//  ImagePageViewController.h
//  VirtualApp
//
//  Created by Michael Toth on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImagePageViewController : UIViewController <NSXMLParserDelegate> {
    BOOL accumulatingChars;
    NSMutableString *currentStringValue;
    NSString *imageFileName;
    NSString *imageID;
}
@property (nonatomic, retain) NSString *imageFileName;
@property (nonatomic, retain) NSString *imageID;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
- (IBAction)share:(id)sender;

@end
