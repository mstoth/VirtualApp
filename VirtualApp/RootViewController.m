//
//  RootViewController.m
//  VirtualApp
//
//  Created by Michael Toth on 4/4/11.
//  Copyright 2011 Michael Toth. All rights reserved.
//

#import "RootViewController.h"
#import "ParseOperation.h"
#import "SiteObject.h"
#import "MenuViewController.h"
#import "SHK.h"
#import "Constants.h"

@implementation RootViewController

@synthesize sitesData;
@synthesize parseQueue;
@synthesize toolBar, tableView;
@synthesize allButtonItem, bookmarksButtonItem, categoriesButtonItem;
@synthesize categoryList,subList, currentCategory;
@synthesize searchBar;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad
{
    NSError *error;
    [super viewDidLoad];
    
    // Uncomment this line if you want to reset your sharing ID information 
    //[SHK logoutOfAll];
    
    
#ifdef MAKE_FOR_CUSTOMER
    self.title = kTitle;
#else
    self.title = @"Virtual App";
#endif
    
    /* create path to cache directory inside the application's Documents directory */
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"VAPP"];
	
	/* check for existence of cache directory */
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error];
	}
	
	/* create a new cache directory */
	[[NSFileManager defaultManager] createDirectoryAtPath:dataPath
                              withIntermediateDirectories:NO
                                               attributes:nil
                                                    error:&error];
	
    
    // initialize lists
    self.categoryList = [[NSMutableArray alloc] init];
    
    parseQueue = [NSOperationQueue new];
    
    [self loadSites];
}


- (void) loadSites {
    
    [self.categoryList release];
	self.categoryList = [[NSMutableArray alloc] init];

    // request the sites xml data
    NSURLRequest *sitesRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:kSitesURL]];
	sitesFeedConnection = [[NSURLConnection alloc] initWithRequest:sitesRequest delegate:self];
    
	NSAssert(sitesFeedConnection != nil, @"Failure to create URL connection for Sites.");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    
#ifdef MAKE_FOR_CUSTOMER
    defaultAppID = kAppID;
    defaultUserID = kUserID;
#else
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    defaultAppID = [defaults stringForKey:@"AppID"];
    defaultUserID = [defaults stringForKey:@"UserID"];
#endif
    
    if (defaultAppID && ![defaultAppID  isEqualToString:@"0"]) { // go to specific app
#ifdef LOCAL
        urlString = [[NSString alloc] initWithFormat:@"http://localhost:3000/system/icons/%@/mainmenu.xml",defaultAppID];
#else
        urlString = [[NSString alloc] initWithFormat:@"http://home.my-iphone-app.com/system/icons/%@/mainmenu.xml",defaultAppID];
#endif
        
        defaultMenuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        defaultMenuViewController.userID = defaultUserID;
        
        if (!url) {
            [defaultMenuViewController release];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL failed" message:url.path delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            [urlString release];
            return;
        }
        
        
        NSURL *baseURL = [url URLByDeletingLastPathComponent];
        [url release];
#ifdef LOCAL
        [defaultMenuViewController setPaths:[baseURL absoluteString] root:@"http://localhost:3000/system" fname:[urlString lastPathComponent]];
#else
        [defaultMenuViewController setPaths:[baseURL absoluteString] 
                                       root:@"http://home.my-iphone-app.com/system" 
                                      fname:[urlString lastPathComponent]];
#endif
        [urlString release];
        [self.navigationController pushViewController:defaultMenuViewController animated:YES];
        [defaultMenuViewController release];
    }
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Search Bar Delegate Routines

- (void) searchBarSearchButtonClicked:(UISearchBar *)search_bar {
    NSString *searchTerm = [searchBar text];
    [self handleSearchForTerm:searchTerm];
}

- (void) searchBar:(UISearchBar *)search_bar textDidChange:(NSString *)searchText   {
    if ([searchText length] == 0) {
        [self resetSearch];
        [tableView reloadData];
        return;
    }
    [self handleSearchForTerm:searchText];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *) search_bar {
    searchBar.text = @"";
    [self resetSearch];
    [tableView reloadData];
    [search_bar resignFirstResponder];
}

#pragma mark -
#pragma mark Search Routines

-(void)resetSearch {
    [self copySites];
}

- (void) handleSearchForTerm:(NSString *)searchTerm {
    NSMutableArray *sitesToRemove = [[NSMutableArray alloc] init];
    [self resetSearch];
    for (SiteObject *site in siteObjects) {
        if ([site.siteTitle rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound) {
            [sitesToRemove addObject:site];
        }
    }
    [copyOfSiteObjects removeObjectsInArray:sitesToRemove];
    [sitesToRemove release];
    [tableView reloadData];
}

#pragma mark -
#pragma mark Filtering Operations

- (NSString *)dataFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}


- (void) openDatabase {
	int results = sqlite3_open([[self dataFilePath] UTF8String], &database);
	if (results != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0,@"Failed to open database.");
	}
	
	NSString *createSQL = @"CREATE TABLE IF NOT EXISTS BOOKMARKS (APPID INTEGER PRIMARY KEY, TITLE TEXT, URL TEXT);";
	char *errorMsg;
	if (sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
		sqlite3_close(database);
        NSString *format = @"Error createing table: %s";
        NSString *msg = [[NSString alloc] initWithFormat:format,errorMsg];
		NSAssert(0,msg);
        [msg release];
	}
}

- (NSInteger) numberOfBookmarks {
	NSInteger count=0;
	[self openDatabase];
	NSString *query = @"SELECT COUNT(*) FROM BOOKMARKS";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
		while (sqlite3_step(statement) == SQLITE_ROW) {
			count = sqlite3_column_int(statement, 0); // number of items
		}
	sqlite3_finalize(statement);
	sqlite3_close(database);
	return count;
}	

- (void)copySites {
    [copyOfSiteObjects release];
    copyOfSiteObjects = [[NSMutableArray alloc] init];
    for (SiteObject *site in siteObjects) {
        [copyOfSiteObjects addObject:site];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	switch (displayMode) {
		case SUBLIST:
			return 1;
			break;
		case ALL:
			return 26;
			break;
		case CATEGORIES:
			return 1;
			break;
		case BOOKMARKS:
			return 1;
			break;
		default:
			break;
	}
    return 1;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
    NSString *a = alphabet;
    NSRange r;
    if (displayMode == ALL) {
        // a better way there must be but... 
        for (NSUInteger i=0; i<26; i++) {
            r.length = 1;
            r.location = i;
            [list addObject:[[a substringWithRange:r] uppercaseString]];
        }
        return list;
    }
    return list;
}

- (NSInteger)numberOfSitesInCategory:(NSString *)category {
	NSInteger total = 0;
	for (SiteObject *site in copyOfSiteObjects) {
		if ([site.category isEqualToString:category]) {
			total++;
		}
	}
	return total;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//NSString *category;
	NSInteger total = 0;
	switch (displayMode) {
		case SUBLIST:
			for (SiteObject *aSite in siteObjects) {
				if ([self.currentCategory isEqualToString:aSite.category]) {
					total++;
				}
			}
			return total;
			break;
		case ALL:
            for (SiteObject *aSite in copyOfSiteObjects) {
                if ([[aSite.siteTitle lowercaseString] characterAtIndex:0]  == [@"abcdefghijklmnopqrstuvwxyz" characterAtIndex:section] ) {
                    total++;
                }
            }
			return total;
			break;
		case BOOKMARKS:
			return [self numberOfBookmarks];
			break;
		case CATEGORIES:
			return [categoryList count];
			break;
		default:
			return 0;
			break;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SiteObject *site;
	NSMutableArray *list;
	static NSString *CellIdentifier = @"Cell";
	UIImage *buttonImage;
	UIButton *button;
    NSUInteger section = [indexPath section];
	NSInteger count = 0;
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	switch (displayMode) {
		case SUBLIST:
			for (SiteObject *aSite in siteObjects) {
				if ([aSite.category isEqualToString:self.currentCategory]) {
					if (count == indexPath.row) {
						cell.textLabel.text = aSite.siteTitle;
						break;
					}
					count++;
				}
			}
			break;
		case ALL:
            list = [[NSMutableArray alloc] init];
            for (site in copyOfSiteObjects) {
                if ([[site.siteTitle lowercaseString] characterAtIndex:0]==[alphabet characterAtIndex:section]) {
                    [list addObject:site];
                }
            }
            
			//site = [siteObjects objectAtIndex:indexPath.row];
            site = [list objectAtIndex:indexPath.row];
			cell.textLabel.text = site.siteTitle;
			
			buttonImage = [UIImage imageNamed:@"bookmark.png"];
			button = [UIButton buttonWithType:UIButtonTypeCustom];
			button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
			[button setBackgroundImage:buttonImage forState:UIControlStateNormal];
			[button setTitle:@"Bookmark" forState:UIControlStateNormal];
			[button addTarget:self action:@selector(addToBookmarks:) forControlEvents:UIControlEventTouchUpInside];
			cell.accessoryView = button;	
			[list release];
			return cell;
			break;
		case CATEGORIES:
			cell.accessoryView = nil;
			cell.textLabel.text = [self.categoryList objectAtIndex:indexPath.row];
			break;
		case BOOKMARKS:
			list = [[NSMutableArray alloc] init];
			[self openDatabase];
			NSString *query = @"SELECT * FROM BOOKMARKS";
			sqlite3_stmt *statement;
			if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
				while (sqlite3_step(statement) == SQLITE_ROW) {
					char *rowData = (char *)sqlite3_column_text(statement, 1); // APPID
					[list addObject:[NSString stringWithUTF8String:rowData]];
				}
			sqlite3_finalize(statement);
			sqlite3_close(database);
			
			buttonImage = [UIImage imageNamed:@"nobookmark.png"];
			button = [UIButton buttonWithType:UIButtonTypeCustom];
			button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
			[button setBackgroundImage:buttonImage forState:UIControlStateNormal];
			[button setTitle:@"Bookmark" forState:UIControlStateNormal];
			[button addTarget:self action:@selector(removeFromBookmarks:) forControlEvents:UIControlEventTouchUpInside];
			cell.accessoryView = button;	
			
			cell.textLabel.text = [list objectAtIndex:indexPath.row];
			[list release];
			list=nil;
			break;
		default:
			cell.textLabel.text = @"Error";
			break;
	}
	return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SiteObject *site;
    char *rowData;
    NSString *stringData;
	NSInteger count = 0;
	NSMutableArray *list = [[NSMutableArray alloc] init];
	NSString *turlString;
	MenuViewController *menuViewController;
    NSURL *url,*baseURL;
    NSUInteger section = [indexPath section];

    if ([siteObjects count] == 0) {
        [list release];
        return;
    }
    
	switch (displayMode) {
        case SUBLIST:
            for (SiteObject *aSite in siteObjects) {
                if ([aSite.category isEqualToString:self.currentCategory]) {
                    if (count == indexPath.row) {
#ifdef LOCAL
                        turlString = [[[NSString alloc] initWithFormat:@"http://localhost:3000/system/icons/%@/mainmenu.xml",aSite.appID] autorelease];
#else
                        turlString = [[[NSString alloc] initWithFormat:@"http://home.my-iphone-app.com/system/icons/%@/mainmenu.xml",aSite.appID] autorelease];
#endif

                        menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
                        NSURL *url = [[NSURL alloc] initWithString:turlString];
                        menuViewController.userID = aSite.userID;
                        
                        if (!url) {
                            [menuViewController release];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL failed" message:url.path delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            [alert release];
                            //[turlString release];
                            [list release];
                            return;
                        }
                        
                        
                        NSURL *baseURL = [url URLByDeletingLastPathComponent];
                        [url release];
                        NSString *tFileName = [[[NSString alloc] initWithString:[turlString lastPathComponent]] autorelease];
#ifdef LOCAL
                        [menuViewController setPaths:[baseURL absoluteString] root:@"http://localhost:3000/system" fname:tFileName];
#else
                        [menuViewController setPaths:[baseURL absoluteString] 
                                                root:@"http://home.my-iphone-app.com/system" 
                                               fname:tFileName];
#endif
                        //[turlString release];
                        //[baseURL release];
                        [tFileName release];
                        [self.navigationController pushViewController:menuViewController animated:YES];
                        [menuViewController release];
                        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                        break;
                    }
                    count++;
                }
            }
            
            break;
            
		case CATEGORIES:
			displayMode = SUBLIST;
			self.currentCategory = [self.categoryList objectAtIndex:indexPath.row];
			[self.tableView reloadData];
			break;
		case BOOKMARKS:
			[self openDatabase];
			NSString *query = @"SELECT * FROM BOOKMARKS";
			sqlite3_stmt *statement;
			if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
				while (sqlite3_step(statement) == SQLITE_ROW) {
					rowData = (char *)sqlite3_column_text(statement, 1); // Title
					stringData = [[NSString alloc] initWithUTF8String:rowData];
                    [list addObject:stringData];
                    [stringData release];
				}
			sqlite3_finalize(statement);
			sqlite3_close(database);
			NSString *chosenTitle = [list objectAtIndex:indexPath.row];
            if ([siteObjects count] == 0) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Sites Loaded" message:@"There are no sites loaded." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [av show];
                [av release];
                [list release];
                return;
            }
            site = [siteObjects objectAtIndex:0];
			for (SiteObject *asite in siteObjects) {
				if ([asite.siteTitle isEqualToString:chosenTitle]) {
					site = asite;
					break;
				}
 			}
#ifdef LOCAL
			turlString = [[NSString alloc] initWithFormat:@"http://localhost:3000/system/icons/%@/mainmenu.xml",site.appID];
#else
			turlString = [[NSString alloc] initWithFormat:@"http://home.my-iphone-app.com/system/icons/%@/mainmenu.xml",site.appID];
#endif
			menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
			url = [[NSURL alloc] initWithString:turlString];
			if (!url) {
				[menuViewController release];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL failed" message:url.path delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
				[alert release];
				[turlString release];
                for (NSString *item in list) {
                    [item release];
                }

				[list release];
                list=nil;
				return;
			}
			
			
			baseURL = [[url URLByDeletingLastPathComponent] retain];
			[url release];
#ifdef LOCAL
            [menuViewController setPaths:[baseURL absoluteString] root:@"http://localhost:3000/system" fname:[turlString lastPathComponent]];
#else
            [menuViewController setPaths:[baseURL absoluteString] root:@"http://home.my-iphone-app.com/system" fname:[turlString lastPathComponent]];
#endif
			menuViewController.userID = site.userID;
			[turlString release];
			[self.navigationController pushViewController:menuViewController animated:YES];
			[menuViewController release];
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [baseURL release];
			break;
		case ALL:
            list = [[NSMutableArray alloc] init];
            for (site in siteObjects) {
                if ([[site.siteTitle lowercaseString] characterAtIndex:0]==[alphabet characterAtIndex:section]) {
                    [list addObject:site];
                }
            }
            
			//site = [siteObjects objectAtIndex:indexPath.row];
            site = [list objectAtIndex:indexPath.row];

            
#ifdef LOCAL
			turlString = [[NSString alloc] initWithFormat:@"http://localhost:3000/system/icons/%@/mainmenu.xml",site.appID];
#else
			turlString = [[NSString alloc] initWithFormat:@"http://home.my-iphone-app.com/system/icons/%@/mainmenu.xml",site.appID];
#endif
           
            
			menuViewController = [[[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil] autorelease];
            
			url = [[NSURL alloc] initWithString:turlString];
            
			if (!url) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL failed" message:turlString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
				[alert release];
                [list release];
				[turlString release];
				return;
			}
			
            NSString *fn = [[[NSString alloc] initWithString:[turlString lastPathComponent]] autorelease];
#ifdef LOCAL
            NSString *ws = [[[NSString alloc] initWithFormat:@"http://localhost:3000/system/icons/%@/",site.appID] autorelease];
            NSString *rs = [[[NSString alloc] initWithFormat:@"http://localhost:3000/system"] autorelease];
#else
            NSString *ws = [[[NSString alloc] initWithFormat:@"http://home.my-iphone-app.com/system/icons/%@/",site.appID] autorelease];
            NSString *rs = [[[NSString alloc] initWithFormat:@"http://home.my-iphone-app.com/system"] autorelease];
#endif
            [menuViewController setPaths:ws root:rs fname:fn];

			menuViewController.userID = site.userID;
            
			[self.navigationController pushViewController:menuViewController animated:YES];
            [fn release];
            [url release];
			[turlString release];
            
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
			break;
		default:
			break;
	}
    [list release];
    list = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	categoryList = nil;
	siteObjects = nil;
    copyOfSiteObjects = nil;
}


- (void)dealloc {
    [sitesFeedConnection release];
    sitesFeedConnection = nil;
    [parseQueue release];
    [sitesData release];
	[categoryList release];
	[siteObjects release];
    [copyOfSiteObjects  release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // check for HTTP status code for proxy authentication failures
    // anything in the 200 to 299 range is considered successful,
    // also make sure the MIMEType is correct:
    //
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    if ((([httpResponse statusCode]/100) == 2) && ([[response MIMEType] isEqual:@"application/xml"] || [[response MIMEType] isEqual:@"text/xml"]) ) {
        self.sitesData = [NSMutableData data];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:
         NSLocalizedString(@"No Connection Error, you need to be connected to the internet to run Virtual App.",
                           @"For Virtual App to work, you need to be connected to the internet.")
                                    forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        [self handleError:error];
    }
    [sitesFeedConnection release];
    sitesFeedConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [sitesData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [sitesFeedConnection release];
    sitesFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.sitesData];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
    [self copySites];
    [self.tableView reloadData];
    
    self.sitesData = nil;
}

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Error",
                       @"Problem downloading or parsing sites file.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


#pragma mark -
#pragma mark Bar Button Item Actions

-(IBAction) allButtonItemPushed:(id)sender {
	displayMode = ALL;
    [self loadSites];
}

-(IBAction) bookmarksButtonItemPushed:(id)sender {
	displayMode = BOOKMARKS;
	[self.tableView reloadData];
}

-(IBAction) categoriesButtonItemPushed:(id)sender {
	displayMode = CATEGORIES;
	[self.tableView reloadData];
}

- (IBAction)addToBookmarks:(id)sender {
	char *errorMsg;
	BOOL alreadyThere;
	alreadyThere = NO;
	UIButton *senderButton = (UIButton*)sender;
	UITableViewCell *buttonCell = (UITableViewCell *)[senderButton superview];
	NSUInteger buttonRow = [[self.tableView indexPathForCell:buttonCell] row];
	SiteObject	*site = [siteObjects objectAtIndex:buttonRow];
	NSString *appID = site.appID;
	NSString *appTitle = site.siteTitle ;
	
	int results = sqlite3_open([[self dataFilePath] UTF8String], &database);
	if (results != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0,@"Failed to open database.");
	}
	NSString *createSQL = @"CREATE TABLE IF NOT EXISTS BOOKMARKS (APPID INTEGER PRIMARY KEY, TITLE TEXT, URL TEXT);";
	if (sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
		sqlite3_close(database);
        NSString *format = @"Error creating table: %s";
        NSString *msg = [[NSString alloc] initWithFormat:format,errorMsg];
		NSAssert(0,msg);
        [msg release];
	}
	// check to see if it's already there. 
	NSString *queryFormat = @"SELECT APPID, TITLE FROM BOOKMARKS WHERE TITLE='%@'";
	NSString *query = [[NSString alloc] initWithFormat:queryFormat,appTitle];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			alreadyThere = YES;
		}
	}
	[query release];
	if (alreadyThere) {
		UIAlertView	*av = [[UIAlertView alloc] initWithTitle:@"Already There" 
													 message:@"You have already bookmarked that site." 
													delegate:self cancelButtonTitle:@"OK" 
										   otherButtonTitles:nil];
		[av show];
		[av release];
	} else {
		NSString *queryFormat = @"INSERT INTO BOOKMARKS (APPID, TITLE) VALUES ('%@','%@')";
		NSString *query = [[NSString alloc] initWithFormat:queryFormat,appID,appTitle];
		if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
			NSAssert(0,@"Failure inserting bookmark.");
		}
		[query release];
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Added to bookmarks." message:appTitle delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[av show];
		[av release];
	}
	sqlite3_close(database);
	[self.tableView reloadData];
}

- (IBAction)removeFromBookmarks:(id)sender {
	char *errorMsg;
	UIButton *senderButton = (UIButton*)sender;
	UITableViewCell *buttonCell = (UITableViewCell *)[senderButton superview];
	NSUInteger buttonRow = [[self.tableView indexPathForCell:buttonCell] row];
    //NSMutableArray *list;
	//SiteObject	*site;
    NSString *title = @"No Title";
    
    //list = [[NSMutableArray alloc] init];
    [self openDatabase];
    NSString *query = @"SELECT * FROM BOOKMARKS";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
        while (sqlite3_step(statement) == SQLITE_ROW) {
            if (buttonRow > 0) {
                buttonRow--;
            } else {
                char *rowData = (char *)sqlite3_column_text(statement, 1);
                title = [[NSString alloc] initWithUTF8String:rowData];
                break;
            }
        }
    sqlite3_finalize(statement);
    sqlite3_close(database);

	//NSString *appTitle = site.siteTitle;
	
	int results = sqlite3_open([[self dataFilePath] UTF8String], &database);
	if (results != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0,@"Failed to open database.");
	}
	
	NSString *queryFormat = @"DELETE FROM BOOKMARKS WHERE TITLE='%@'";
	query = [[NSString alloc] initWithFormat:queryFormat,title];
	if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
		NSAssert(0,@"Failure deleting bookmark.");
	}
	[query release];
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Deleted Bookmark." message:title delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[av show];
	[av release];
    [title release];

	sqlite3_close(database);
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark NSXMLParser delegate routines

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"apps"]) {
        siteObjects = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:@"app"]) {
        currentSite = [[SiteObject alloc] init];
    }
    if ([elementName isEqualToString:@"category"] ||
        [elementName isEqualToString:@"id"] ||
        [elementName isEqualToString:@"title"] ||
        [elementName isEqualToString:@"icon-file-name"] ||
        [elementName isEqualToString:@"user-id"]) {
        accumulatingChars = YES;
        currentStringValue = [[NSMutableString alloc] init];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {   
    
    if ([elementName isEqualToString:@"app"]) {
        [siteObjects addObject:currentSite];
        [currentStringValue release];
        currentStringValue = nil;
        [currentSite release];
        currentSite = nil;
    }
    if ([elementName isEqualToString:@"category"]) {
        currentSite.category = currentStringValue;
        accumulatingChars = NO;
        if ([self.categoryList indexOfObject:currentStringValue] == NSNotFound)
            [self.categoryList addObject:currentStringValue];
        [currentStringValue release];
        currentStringValue = nil;
    }
    if ([elementName isEqualToString:@"id"]) {
        currentSite.appID = currentStringValue;
        accumulatingChars = NO;
        [currentStringValue release];
        currentStringValue = nil;
    }
    if ([elementName isEqualToString:@"title"]) {
        currentSite.siteTitle = currentStringValue;
        accumulatingChars = NO;
        [currentStringValue release];
        currentStringValue = nil;
    }
    if ([elementName isEqualToString:@"icon-file-name"]) {
        currentSite.filename = currentStringValue;
        accumulatingChars = NO;
        [currentStringValue release];
        currentStringValue = nil;
    }
    if ([elementName isEqualToString:@"user-id"]) {
        currentSite.userID = currentStringValue;
        accumulatingChars = NO;
        [currentStringValue release];
        currentStringValue = nil;
    }
    
}



- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingChars) {
        [currentStringValue appendString:string];
    }
}



@end
