//
//  TextViewController.h
//  VirtualApp
//
//  Created by Michael Toth on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextViewController : UIViewController <NSXMLParserDelegate> {
    BOOL accumulatingChars;
    NSMutableString *currentStringValue;
    UIWebView *webView;
}
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *fileName;
@end
