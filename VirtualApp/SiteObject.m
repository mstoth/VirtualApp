//
//  SiteObject.m
//  vapp2
//
//  Created by Michael Toth on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SiteObject.h"


@implementation SiteObject

@synthesize siteTitle, appID, userID, filename, category;

-(id)initWithSiteObject:(SiteObject *)siteObject {
    siteTitle = siteObject.siteTitle;
    appID = siteObject.appID;
    userID = siteObject.userID;
    filename = siteObject.filename;
    category = siteObject.category;
    [super init];
    return self;
}

/*
-(id)init {
    [super init];
    siteTitle = [[NSString alloc] init];
    appID = [[NSString alloc] init];
    userID = [[NSString alloc] init];
    filename = [[NSString alloc] init];
    category = [[NSString alloc] init];
                 
}
*/
-(void)dealloc {
	[siteTitle release];
	[appID release];
	[userID release];
	[filename release];
	[category release];
	[super dealloc];
}
@end
