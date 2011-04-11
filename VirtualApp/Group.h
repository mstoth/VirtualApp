//
//  Group.h
//  VirtualApp
//
//  Created by Michael Toth on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupItem.h"

@interface Group : NSObject {
    NSMutableArray *groupItems;
}
@property (nonatomic, retain) NSMutableArray *groupItems;
@end
