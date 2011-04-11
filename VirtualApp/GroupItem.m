//
//  GroupItem.m
//  VirtualApp
//
//  Created by Michael Toth on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GroupItem.h"


@implementation GroupItem
@synthesize name,image,info,more;
-(void)dealloc {
    [name release];
    [image release];
    [info release];
    [more release];
    [super dealloc];
}
@end
