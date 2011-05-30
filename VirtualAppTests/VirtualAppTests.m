//
//  VirtualAppTests.m
//  VirtualAppTests
//
//  Created by Michael Toth on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VirtualAppTests.h"
#import "RootViewController.h"

@implementation VirtualAppTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    RootViewController *rvc = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    
    STFail(@"Unit tests are not implemented yet in VirtualAppTests");
}

@end
