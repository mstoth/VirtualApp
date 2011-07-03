//
//  CalAppParser.h
//  VirtualApp
//
//  Created by Michael Toth on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CalAppParser : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentStringValue;
    BOOL accumulatingChars;
}
@property (nonatomic, retain) NSString *username, *password, *title;
@end
