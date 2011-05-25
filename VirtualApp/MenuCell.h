//
//  MenuCell.h
//  VirtualApp
//
//  Created by Michael Toth on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MenuCell : UITableViewCell {
    UILabel *title;
    UITextView *description;
}
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UITextView *description;
@end
