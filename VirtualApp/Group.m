//
//  Group.m
//  VirtualApp
//
//  Created by Michael Toth on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Group.h"
#import "GroupItem.h"

@implementation Group
@synthesize groupItems;

-(void)dealloc {
    [groupItems release];
    [super dealloc];
}
@end
