
#import <Foundation/Foundation.h>


@interface PayPalInvoiceItem : NSObject {
	@private
	
//optional
	NSString *name;
	NSString *itemId;
	NSDecimalNumber *totalPrice;
	NSDecimalNumber *itemPrice;
	NSNumber *itemCount;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *itemId;
@property (nonatomic, retain) NSDecimalNumber *totalPrice;
@property (nonatomic, retain) NSDecimalNumber *itemPrice;
@property (nonatomic, retain) NSNumber *itemCount;

@end
