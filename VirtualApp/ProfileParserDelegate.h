//
//  ProfileParserDelegate.h
//  vapp2
//
//  Created by Michael Toth on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProfileParserDelegate : NSObject <NSXMLParserDelegate> {
	NSString *userName, *street, *cityStateZip, *phone, *email, *longitude, *latitude; 
	NSMutableString *currentStringValue;
}

@property (nonatomic, retain) NSString *userName, *street, *cityStateZip, *phone, *email, *longitude, *latitude; 

@end
