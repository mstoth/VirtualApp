//
//  GroupParserDelegate.h
//  VirtualApp
//
//  Created by Michael Toth on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"
#import "GroupItem.h"


@interface GroupParserDelegate : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentStringValue;
    GroupItem *currentGroupItem;
    NSMutableArray *groupItems;
    BOOL accumulatingChars;
    NSString *groupTitle;
}
@property (nonatomic, retain) NSMutableString *currentStringValue;
@property (nonatomic, retain) GroupItem *currentGroupItem;
@property (nonatomic, retain) NSMutableArray *groupItems;
@property (nonatomic, retain) NSString *groupTitle;

@end
