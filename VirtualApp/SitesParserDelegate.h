//
//  SitesParserDelegate.h
//  VirtualApp
//
//  Created by Michael Toth on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SiteObject.h"

@interface SitesParserDelegate : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentStringValue;
    SiteObject *currentSite;
    NSMutableArray *siteObjects;
    BOOL accumulatingChars;
}
@property (nonatomic, retain) NSMutableString *currentStringValue;
@property (nonatomic, retain) SiteObject *currentSite;
@property (nonatomic, retain) NSMutableArray *siteObjects;
@end
