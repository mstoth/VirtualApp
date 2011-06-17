//
//  VirtualAppAppDelegate.m
//  VirtualApp
//
//  Created by Michael Toth on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VirtualAppAppDelegate.h"
#import "Constants.h"
#import "PayPal.h"

#ifdef MAKE_FOR_CUSTOMER
#import "MenuViewController.h"
#endif

@implementation VirtualAppAppDelegate


@synthesize window=_window;

@synthesize navigationController=_navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];

#ifdef MAKE_FOR_CUSTOMER
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    MenuViewController *mvc = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    [mvc setPaths:kWebPath root:kRootPath fname:kFileName];
    [self.navigationController initWithRootViewController:mvc];
    mvc.title = kTitle;
    mvc.userID = kUserID;
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    [mvc release];
#else // VIRTUALAPP
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
#endif
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

@end
