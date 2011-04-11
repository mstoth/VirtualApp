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

@implementation RootViewController

@synthesize siteList, sitesData, sitesFeedConnection;
@synthesize parseQueue;
@synthesize toolBar, tableView;
@synthesize allButtonItem, bookmarksButtonItem, categoriesButtonItem;
@synthesize categoryList,subList, currentCategory;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Virtual App";
	
	// initialize lists
	self.siteList = [[NSMutableArray alloc] init];
	self.categoryList = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addSites:)
                                                 name:@"addSites"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sitesError:)
                                                 name:kSitesErrorNotif
                                               object:nil];	
    parseQueue = [NSOperationQueue new];

    [self loadSites];
}


- (void) loadSites {
    
    [self.siteList release];
    [self.categoryList release];
    self.siteList = [[NSMutableArray alloc] init];
	self.categoryList = [[NSMutableArray alloc] init];

    // request the sites xml data
    NSURLRequest *sitesRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:kSitesURL]];
	self.sitesFeedConnection = [[NSURLConnection alloc] initWithRequest:sitesRequest delegate:self];
    
	NSAssert(self.sitesFeedConnection != nil, @"Failure to create URL connection for Sites.");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
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


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	switch (displayMode) {
		case SUBLIST:
			return 1;
			break;
		case ALL:
			return 1;
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

- (NSInteger)numberOfSitesInCategory:(NSString *)category {
	NSInteger total = 0;
	for (SiteObject *site in siteList) {
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
			for (SiteObject *aSite in self.siteList) {
				if ([self.currentCategory isEqualToString:aSite.category]) {
					total++;
				}
			}
			return total;
			break;
		case ALL:
			return [siteList count];
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
	NSInteger count = 0;
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	switch (displayMode) {
		case SUBLIST:
			for (SiteObject *aSite in self.siteList) {
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
			site = [siteList objectAtIndex:indexPath.row];
			cell.textLabel.text = site.siteTitle;
			
			buttonImage = [UIImage imageNamed:@"bookmark.png"];
			button = [UIButton buttonWithType:UIButtonTypeCustom];
			button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
			[button setBackgroundImage:buttonImage forState:UIControlStateNormal];
			[button setTitle:@"Bookmark" forState:UIControlStateNormal];
			[button addTarget:self action:@selector(addToBookmarks:) forControlEvents:UIControlEventTouchUpInside];
			cell.accessoryView = button;	
			
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
	NSString *urlString;
	MenuViewController *menuViewController;
    NSURL *url,*baseURL;
    
    if ([siteList count] == 0) {
        [list release];
        return;
    }
    
	switch (displayMode) {
        case SUBLIST:
            for (SiteObject *aSite in self.siteList) {
                if ([aSite.category isEqualToString:self.currentCategory]) {
                    if (count == indexPath.row) {
                        urlString = [[NSString alloc] initWithFormat:@"http://vsec.railsplayground.net/system/icons/%@/mainmenu.xml",aSite.appID];
                        menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
                        NSURL *url = [[NSURL alloc] initWithString:urlString];
                        menuViewController.userID = aSite.userID;
                        
                        if (!url) {
                            [menuViewController release];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL failed" message:url.path delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            [alert release];
                            [urlString release];
                            [list release];
                            return;
                        }
                        
                        
                        NSURL *baseURL = [url URLByDeletingLastPathComponent];
                        [url release];
                        menuViewController.webSite = [[baseURL absoluteString] autorelease];
                        menuViewController.fileName = [[urlString lastPathComponent] autorelease];
                        [urlString release];
                        //[baseURL release];
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
            if ([self.siteList count] == 0) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Sites Loaded" message:@"There are no sites loaded." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [av show];
                [av release];
                [list release];
                return;
            }
            site = [self.siteList objectAtIndex:0];
			for (SiteObject *asite in self.siteList) {
				if ([asite.siteTitle isEqualToString:chosenTitle]) {
					site = asite;
					break;
				}
 			}
            
			urlString = [[NSString alloc] initWithFormat:@"http://vsec.railsplayground.net/system/icons/%@/mainmenu.xml",site.appID];
			menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
			url = [[NSURL alloc] initWithString:urlString];
			if (!url) {
				[menuViewController release];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL failed" message:url.path delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
				[alert release];
				[urlString release];
                for (NSString *item in list) {
                    [item release];
                }

				[list release];
                list=nil;
				return;
			}
			
			
			baseURL = [[url URLByDeletingLastPathComponent] retain];
			[url release];
			menuViewController.webSite = [baseURL absoluteString];
			menuViewController.userID = site.userID;
			menuViewController.fileName = [urlString lastPathComponent];
			[urlString release];
			[self.navigationController pushViewController:menuViewController animated:YES];
			[menuViewController release];
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [baseURL release];
			break;
		case ALL:
			site = [self.siteList objectAtIndex:indexPath.row];
            
			urlString = [[NSString alloc] initWithFormat:@"http://vsec.railsplayground.net/system/icons/%@/mainmenu.xml",site.appID];
            
			menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
            
			url = [[NSURL alloc] initWithString:urlString];
            
			if (!url) {
				[menuViewController release];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL failed" message:url.path delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
				[alert release];
                [list release];
				[urlString release];
				return;
			}
			
			
			menuViewController.webSite = [[[NSString alloc] initWithFormat:@"http://vsec.railsplayground.net/system/icons/%@/",site.appID] autorelease];
			menuViewController.userID = site.userID;
			menuViewController.fileName = [[urlString lastPathComponent] autorelease];
            
			[self.navigationController pushViewController:menuViewController animated:YES];
            
			[menuViewController release];
            [url release];
			[urlString release];
            
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
	siteList = nil;
}


- (void)dealloc {
    [sitesFeedConnection release];
    sitesFeedConnection = nil;
    [parseQueue release];
    [sitesData release];
	[categoryList release];
	[siteList release];
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

    if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"application/xml"]) {
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
    self.sitesFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    ParseOperation *parseOperation = [[ParseOperation alloc] initWithDataAndType:self.sitesData type:@"App"];
	parseOperation.objectType = @"App";
    [self.parseQueue addOperation:parseOperation];
    [parseOperation release];       
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

- (void)addSites:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    [self addSitesToList:[[notif userInfo] valueForKey:@"sitesResult"]];
}

- (void)sitesError:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:kSitesMsgErrorKey]];
}

- (void)addSitesToList:(NSArray *)sitesArray {
	[self insertSites:sitesArray];
	[self.tableView reloadData];
}

- (void)insertSites:(NSArray *)sitesArray
{
    // this will allow us as an observer to notified (see observeValueForKeyPath)
    // so we can update our UITableView
    //
	
    [self willChangeValueForKey:@"siteList"];
    [self.siteList addObjectsFromArray:sitesArray];
	[self didChangeValueForKey:@"siteList"];
	// pull out the unique categories 
	
	for (SiteObject *site in sitesArray) {
		if ([self.categoryList indexOfObject:site.category] == NSNotFound) {
			[self.categoryList addObject:site.category];
		}
	} 
	
	[self.tableView reloadData];
	
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
	SiteObject	*site = [siteList objectAtIndex:buttonRow];
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


@end
