
#import <Foundation/Foundation.h>
#import "PPReceiverPaymentDetails.h"

@interface PayPalAdvancedPayment : NSObject {
	@private
	
//required
	NSString *paymentCurrency; //you can specify only one currency, regardless of the number of receivers
	NSMutableArray *receiverPaymentDetails; //array of PPReceiverPaymentDetails
	
//optional
	NSString *merchantName; //this will be displayed at the top of all library screens
	NSString *ipnUrl;
	NSString *memo;
}

@property (nonatomic, retain) NSString *paymentCurrency;
@property (nonatomic, retain) NSMutableArray *receiverPaymentDetails;

//if set, the value of this property will be displayed at the top of all library screens
//if not set:
//1. single receiver (simple or chain payment) this property will return the merchant name or email address of the primary/single receiver
//2. multiple receivers (parallel payment) this property will return first merchant name it finds, or first email/phone
@property (nonatomic, retain) NSString *merchantName;

@property (nonatomic, retain) NSString *ipnUrl;
@property (nonatomic, retain) NSString *memo;

@property (nonatomic, readonly) NSDecimalNumber *subtotal; //summed over all receivers
@property (nonatomic, readonly) NSDecimalNumber *tax;      //summed over all receivers
@property (nonatomic, readonly) NSDecimalNumber *shipping; //summed over all receivers
@property (nonatomic, readonly) NSDecimalNumber *total;    //subtotal + tax + shipping, summed over all receivers

//returns primary receiver if we are doing chain payment
//returns single receiver if we only have one receiver
@property (nonatomic, readonly) PPReceiverPaymentDetails *singleReceiver;

//convenience property indicating if this is a personal payment
//this will return TRUE if any receiver has a payment type of personal
@property (nonatomic, readonly) BOOL isPersonal;

@end
