//
//  MapViewController.h
//  Paparazzi
//
//  Created by byeong cheol lim on 11. 1. 8..
//  Copyright 2011 ocbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FlickrFetcher.h"
#import "Person.h"
#import "Photo.h"
#import "Scale.h"
#import "ThirdPersonViewController.h"
#import "Annotation.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, UIAlertViewDelegate>{
	IBOutlet MKMapView *mapView;
	IBOutlet UISegmentedControl *segControl;
	FlickrFetcher *flicker;
	Person *person;
	Photo *photo;
	Annotation *sharedAnnotation;
	NSManagedObjectContext *context;
	NSArray *fArray;
	NSString *phoName;
	ThirdPersonViewController *thirdVC;
	Boolean run;
	int idx;
	BOOL updatingCoredata;

}
@property (nonatomic,retain) MKMapView *mapView;
@property (nonatomic,retain) UIImage *annoImage;
@property (nonatomic,retain) NSString *phoName;
@property (nonatomic,retain) Annotation *sharedAnnotation;
@property (nonatomic,assign) 	BOOL updatingCoredata;
-(IBAction)addAnnotation;
-(IBAction)changeMapType;
-(void)updateMap:(NSNumber *)object;
-(void)checkButtonTapped:(id)sender event:(UIEvent *)event;
@end
