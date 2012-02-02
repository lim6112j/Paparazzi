//
//  PersonListViewController.h
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 11. 22..
//  Copyright 2010 ocbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SecondPersonViewController.h"
#import "FlickrFetcher.h"
#import "Person.h"
#import "Photo.h"
#import "AddModalViewController.h"
#import "MapViewController.h"

@interface PersonListViewController : UITableViewController <UITextFieldDelegate> {

	SecondPersonViewController *sPVC;
	FlickrFetcher *flicker;
	NSFetchedResultsController *_fetchedResultsController;
	NSManagedObjectContext *_context;
	IBOutlet UIBarButtonItem *barButton;
	IBOutlet UIBarButtonItem *barButtonLeft;
	NSString *inputName;
	AddModalViewController *modalView;
	MapViewController *mapViewController;
	UIActivityIndicatorView *av;
	Boolean updateCoreData;


}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic,retain) FlickrFetcher *flicker;
@property (nonatomic,retain) Person *person;
@property (nonatomic,retain) Photo *photo;
@property (nonatomic,retain) NSString *inputName;
@property (nonatomic,retain) NSCondition *condition;
-(IBAction)addPerson;
-(void)retainCountLog:(id)obj;
-(void)insertPerson:(NSString *)object;
-(IBAction)defaultPerson;
-(void)threadDone:(id)object;
-(void)startSpinner;
@end
