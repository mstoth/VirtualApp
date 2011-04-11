//
//  GroupItem.h
//  VirtualApp
//
//  Created by Michael Toth on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GroupItem : NSObject {
    NSString *name, *image, *info, *more;
}
@property (nonatomic, retain) NSString *name, *image, *info, *more;
@end
