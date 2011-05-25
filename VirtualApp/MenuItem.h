//
//  MenuItem.h
//  vapp2
//
//  Created by Michael Toth on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MenuItem : NSObject {
	NSString *itemTitle, *pageType, *fileName, *description;
}
@property (nonatomic, retain) NSString *itemTitle, *pageType, *fileName, *description;
- (id)initWithMenuItem:(MenuItem *)menuItem;

@end
