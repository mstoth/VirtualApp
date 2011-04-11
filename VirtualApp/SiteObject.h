//
//  SiteObject.h
//  vapp2
//
//  Created by Michael Toth on 3/28/11.
//  Copyright 2011 Michael Toth. All rights reserved.
//
/* example xml data
 
 <apps type="array">
 −
 <app>
 <category>test</category>
 <created-at type="datetime">2011-03-09T09:05:57Z</created-at>
 <title>test</title>
 <updated-at type="datetime">2011-03-09T09:06:20Z</updated-at>
 <id type="integer">8</id>
 <live type="boolean">true</live>
 <user-id type="integer">1</user-id>
 <icon-content-type>image/jpeg</icon-content-type>
 <icon-file-name>Boris 80 x 80.jpg</icon-file-name>
 <icon-file-size type="integer">5567</icon-file-size>
 <link type="integer" nil="true"/>
 <icon-updated-at type="datetime">2011-03-09T09:05:56Z</icon-updated-at>
 </app>
 −
 <app>
 <category>Introduction</category>
 <created-at type="datetime">2011-03-10T07:24:02Z</created-at>
 <title>Hello World</title>
 <updated-at type="datetime">2011-03-20T03:23:28Z</updated-at>
 <id type="integer">9</id>
 <live type="boolean">true</live>
 <user-id type="integer">1</user-id>
 <icon-content-type>image/png</icon-content-type>
 <icon-file-name>virtual app icon 512x512.png</icon-file-name>
 <icon-file-size type="integer">65264</icon-file-size>
 <link type="integer" nil="true"/>
 <icon-updated-at type="datetime">2011-03-10T07:24:00Z</icon-updated-at>
 </app>
 </apps>
 */

#import <Foundation/Foundation.h>


@interface SiteObject : NSObject {
	NSString *siteTitle, *appID, *userID, *filename, *category;
}

@property (nonatomic, retain) NSString *siteTitle;
@property (nonatomic, retain) NSString *appID, *userID, *filename, *category;
-(id)initWithSiteObject:(SiteObject *)siteObject;

@end
