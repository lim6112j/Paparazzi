//
//  SecondPersonViewController.h
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 11. 23..
//  Copyright 2010 ocbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThirdPersonViewController.h"
#import "FlickrFetcher.h"
#import "Person.h"
#import "Photo.h"
@interface SecondPersonViewController :UITableViewController <NSFetchedResultsControllerDelegate> {
	ThirdPersonViewController *thirdView;
	Person *person;
	Photo *photo;
	FlickrFetcher *flicker;
	NSManagedObjectContext *_sharedContext;
	NSFetchedResultsController *_fetchedResultsController;
}
@property(nonatomic,retain)Person *person;
@property(nonatomic,retain)Photo *photo;
@property(nonatomic,retain) NSManagedObjectContext *sharedContext;
@property(nonatomic,retain) NSFetchedResultsController *fetchedResultsController;
-(void)retainCountLog:(id)obj;
@end
