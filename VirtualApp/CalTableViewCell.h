//
//  CalTableViewCell.h
//  VirtualApp
//
//  Created by Michael Toth on 7/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CalTableViewCell : UITableViewCell {
    
}
@property (nonatomic,retain) IBOutlet UILabel *eventTitle;
@property (nonatomic,retain) IBOutlet UILabel *eventTime;
@property (nonatomic,retain) IBOutlet UITextView *content;
@property (nonatomic,retain) IBOutlet UIImageView *imageView;
@property (nonatomic,retain) IBOutlet UIView *viewForBackground;
@end
