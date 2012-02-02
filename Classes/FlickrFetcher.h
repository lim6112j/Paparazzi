//
//  FlickrFetcher.h
//  Flickr3
//
//  Created by Alan Cannistraro on 11/20/09.
//  Copyright 2009 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#define TEST_HIGH_NETWORK_LATENCY 0

typedef enum {
	FlickrFetcherPhotoFormatSquare,
	FlickrFetcherPhotoFormatLarge
} FlickrFetcherPhotoFormat;

@interface FlickrFetcher : NSObject {
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

// Returns the 'singleton' instance of this class
+ (id)sharedInstance;

//
// Local Database Access
//

// Checks to see if any database exists on disk
- (BOOL)databaseExists;

// Returns the NSManagedObjectContext for inserting and fetching objects into the store
- (NSManagedObjectContext *)managedObjectContext;

// Returns an array of objects already in the database for the given Entity Name and Predicate
- (NSArray *)fetchManagedObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate;

// Returns an NSFetchedResultsController for a given Entity Name and Predicate
- (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate;

//
// Flickr API access
// NOTE: these are blocking methods that wrap the Flickr API and wait on the results of a network request
//

// Returns an array of Flickr photo information for photos with the given tag
- (NSArray *)photosForUser:(NSString *)username;

// Returns an array of the most recent geo-tagged photos
- (NSArray *)recentGeoTaggedPhotos;

// Returns a dictionary of user info for a given user ID. individual photos contain a user ID keyed as "owner"
- (NSString *)usernameForUserID:(NSString *)userID;

// Returns the photo for a given server, id and secret
- (NSData *)dataForPhotoID:(NSString *)photoID fromFarm:(NSString *)farm onServer:(NSString *)server withSecret:(NSString *)secret inFormat:(FlickrFetcherPhotoFormat)format;

// Returns a dictionary containing the latitue and longitude where the photo was taken (among other information)
- (NSDictionary *)locationForPhotoID:(NSString *)photoID;

@end
