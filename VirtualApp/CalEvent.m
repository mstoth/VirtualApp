//
//  CalEvent.m
//  VirtualApp
//
//  Created by Michael Toth on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalEvent.h"


@implementation CalEvent
@synthesize title,content,start_time,end_time,whereItIs;

- (void) dealloc {
    [title release];
    [content release];
    [start_time release];
    [end_time release];
    [whereItIs release];
    [super dealloc];
}
@end
