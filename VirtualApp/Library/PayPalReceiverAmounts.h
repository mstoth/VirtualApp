
#import <Foundation/Foundation.h>
#import "PayPalAmounts.h"

@interface PayPalReceiverAmounts : NSObject {
	PayPalAmounts *amounts;
	NSString *recipient;
}
@property (nonatomic, retain) PayPalAmounts *amounts;
@property (nonatomic, copy) NSString *recipient;

@end
