//
//  CalEvent.h
//  VirtualApp
//
//  Created by Michael Toth on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CalEvent : NSObject {

}
@property (nonatomic, retain)  NSString *title;
@property (nonatomic, retain)  NSString *content;
@property (nonatomic, retain)  NSString *whereItIs;
@property (nonatomic, retain)  NSString *start_time;
@property (nonatomic, retain)  NSString *end_time;

@end
