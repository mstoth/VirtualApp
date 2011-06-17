
#import <Foundation/Foundation.h>


@interface PayPalInvoiceData : NSObject {
	@private
	
//optional
	NSDecimalNumber *totalTax;
	NSDecimalNumber *totalShipping;
	NSMutableArray *invoiceItems; // Array of PayPalInvoiceItems
}

@property (nonatomic, retain) NSDecimalNumber *totalTax;
@property (nonatomic, retain) NSDecimalNumber *totalShipping;
@property (nonatomic, retain) NSMutableArray *invoiceItems;

@end
