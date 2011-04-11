//
//  GeneralParser.h
//  VirtualApp
//
//  Created by Michael Toth on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//
//#import <Foundation/Foundation.h>


@interface GeneralParser : NSOperation <NSXMLParserDelegate> {
    
    NSMutableDictionary *parsedData;
    NSData *dataIn;
    
    @private
    NSMutableArray *currentParseBatch;
    NSMutableString *currentParsedCharacterData;
    
    BOOL accumulatingParsedCharacterData;
    BOOL didAbortParsing;
    NSString *firstElementName;
}
@property (nonatomic, retain) NSMutableDictionary *parsedData;
@property (copy, readonly) NSData *dataIn;

- (id) initWithData:(NSData *)appData;

@end
