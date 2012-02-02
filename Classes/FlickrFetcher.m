//
//  FlickrFetcher.m
//  Flickr2
//
//  Created by Alan Cannistraro on 11/20/09.
//  Copyright 2009 Apple. All rights reserved.
//

#import "FlickrFetcher.h"
#import "FlickrAPIKey.h"
#import "JSON.h"

@interface FlickrFetcher ()

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;

@end

@implementation FlickrFetcher

+ (id)sharedInstance
{
	static id master = nil;
	
	@synchronized(self)
	{
		if (master == nil)
			master = [self new];
	}
    return master;
}

- (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate {
    NSFetchedResultsController *fetchedResultsController;
    
    /*
	 Set up the fetched results controller.
     */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor;
	if (entityName==@"Person") {
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userName" ascending:NO];
	} else {
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"photoName" ascending:NO];
	}

	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    // Add a predicate if we're filtering by user name
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:@"Root"];
	
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}

- (NSArray *)fetchManagedObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate
{

	NSManagedObjectContext	*context = [self managedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	
	NSFetchRequest	*request = [[NSFetchRequest alloc] init];
	request.entity = entity;
	request.predicate = predicate;
	NSSortDescriptor *sortDiscriptor;
	if (entityName==@"Annotation") {
		NSLog(@"Annotation data calling , sorted by 'idx'");
		sortDiscriptor =[[NSSortDescriptor alloc] initWithKey:@"idx" ascending:NO];
		NSArray *sortDiscriptors=[NSArray arrayWithObjects:sortDiscriptor,nil];
		[request setSortDescriptors:sortDiscriptors];
	}
	NSArray	*results = [context executeFetchRequest:request error:nil];
	[request release];
	
	return results;

}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (NSString *)databasePath
{
	return [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"temp.sqlite"];
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSString	*path = [self databasePath];
    NSURL *storeUrl = [NSURL fileURLWithPath:path];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
	
    return persistentStoreCoordinator;
}

- (BOOL)databaseExists
{
	NSString	*path = [self databasePath];
	BOOL		databaseExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	
	return databaseExists;
}


#pragma mark -
#pragma mark Flickr API Access

- (NSString *)nsidForUserName:(NSString *)username {
	// Construct a Flickr API request.
	NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.people.findByUsername&api_key=%@&username=%@&format=json&nojsoncallback=1", FlickrAPIKey, username];
	NSURL *url = [NSURL URLWithString:urlString];
	
	// Get the contents of the URL as a string, and parse the JSON into Foundation objects.
	NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	NSDictionary *results = [jsonString JSONValue];
	
	// Now we need to dig through the resulting objects.
	// Read the documentation and make liberal use of the debugger or logs.
	return [[results objectForKey:@"user"] objectForKey:@"nsid"];
}

- (NSArray *)photosForUser:(NSString *)username {
#if TEST_HIGH_NETWORK_LATENCY
	sleep(1);
#endif
	
	// Construct a Flickr API request.
	NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&user_id=%@&per_page=10&format=json&nojsoncallback=1", FlickrAPIKey, [self nsidForUserName:username]];
	NSURL *url = [NSURL URLWithString:urlString];
	
	// Get the contents of the URL as a string, and parse the JSON into Foundation objects.
	NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	NSLog(@"jsonString is %@",jsonString);
	NSDictionary *results = [jsonString JSONValue];
	
	// Now we need to dig through the resulting objects.
	// Read the documentation and make liberal use of the debugger or logs.
	return [[results objectForKey:@"photos"] objectForKey:@"photo"];
}

- (NSArray *)recentGeoTaggedPhotos {
	// Construct a Flickr API request.
	NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&has_geo=1&per_page=10&format=json&nojsoncallback=1", FlickrAPIKey];
	NSURL *url = [NSURL URLWithString:urlString];
	
	// Get the contents of the URL as a string, and parse the JSON into Foundation objects.
	NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	NSDictionary *results = [jsonString JSONValue];
	
	// Now we need to dig through the resulting objects.
	// Read the documentation and make liberal use of the debugger or logs.
	return [[results objectForKey:@"photos"] objectForKey:@"photo"];
}

- (NSString *)usernameForUserID:(NSString *)userID {
#if TEST_HIGH_NETWORK_LATENCY
	sleep(1);
#endif
	
	NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.people.getInfo&api_key=%@&user_id=%@&per_page=10&format=json&nojsoncallback=1", FlickrAPIKey, userID];
	NSURL *url = [NSURL URLWithString:urlString];
	NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	
	return [[[[jsonString JSONValue] valueForKey:@"person"] valueForKey:@"username"] valueForKey:@"_content"];
}

- (NSData *)dataForPhotoID:(NSString *)photoID fromFarm:(NSString *)farm onServer:(NSString *)server withSecret:(NSString *)secret inFormat:(FlickrFetcherPhotoFormat)format {
#if TEST_HIGH_NETWORK_LATENCY
	sleep(1);
#endif
	
	NSString *formatString;
	
	switch (format) {
		case FlickrFetcherPhotoFormatSquare:    formatString = @"s"; break;
//		case FlickrFetcherPhotoFormatThumbnail: formatString = @"t"; break;
//		case FlickrFetcherPhotoFormatSmall:     formatString = @"m"; break;
//		case FlickrFetcherPhotoFormatMedium:    formatString = @"-"; break;
		case FlickrFetcherPhotoFormatLarge:     formatString = @"b"; break;
//		case FlickrFetcherPhotoFormatOriginal:  formatString = @"o"; break;
	}
	
	NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_%@.jpg", farm, server, photoID, secret, formatString];
	NSURL *url = [NSURL URLWithString:photoURLString];
	
	return [NSData dataWithContentsOfURL:url];
}

- (NSDictionary *)locationForPhotoID:(NSString *)photoID {
#if TEST_HIGH_NETWORK_LATENCY
	sleep(1);
#endif
	
	NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.geo.getLocation&api_key=%@&photo_id=%@&format=json&nojsoncallback=1", FlickrAPIKey, photoID];
	NSURL *url = [NSURL URLWithString:urlString];
	NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	
	return [[[jsonString JSONValue] valueForKey:@"photo"] valueForKey:@"location"];
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];

    [super dealloc];
}

@end
