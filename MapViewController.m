//
//  MapViewController.m
//  Paparazzi
//
//  Created by byeong cheol lim on 11. 1. 8..
//  Copyright 2011 ocbs. All rights reserved.
//

#import "MapViewController.h"


@implementation MapViewController
@synthesize mapView,annoImage,phoName,sharedAnnotation,updatingCoredata;

-(IBAction)addAnnotation{
	CLLocationCoordinate2D coordinate2={
		48.858196,2.294748};
	NSDictionary *address=nil;
	MKPlacemark *paris=[[MKPlacemark alloc]initWithCoordinate:coordinate2 addressDictionary:address];
	[mapView addAnnotation:paris];
	[paris release];
}
-(IBAction)changeMapType{
	NSLog(@"Map Type changed");
	if (segControl.selectedSegmentIndex==0) {
		NSLog(@"segControl value %d",segControl.selectedSegmentIndex);
		mapView.mapType=MKMapTypeStandard;
	} else {
		NSLog(@"segControl value %d",segControl.selectedSegmentIndex);
		mapView.mapType=MKMapTypeSatellite;
	}
}

#pragma mark -
#pragma mark Annotation을 맵에 추가함.
-(void)updateMap:(NSNumber *)object{
	
	if ([object boolValue]==NO) {
		
		
		NSLog(@"map view is updating");
		run=NO;
		NSArray *oldAnnotations = mapView.annotations;
		[mapView removeAnnotations:oldAnnotations];
		flicker=[FlickrFetcher sharedInstance];
		context=[flicker managedObjectContext];
		fArray=[flicker fetchManagedObjectsForEntity:@"Photo" withPredicate:nil];
		NSArray *array=[flicker fetchManagedObjectsForEntity:@"Annotation" withPredicate:nil];
		for (int i=0; i<[array count]; i++) {
			[context deleteObject:[array objectAtIndex:i]];
		}
		NSError *error;
		[context save:&error];
		//NSLog(@"farray has %d retain count",[fArray retainCount]);
		NSEnumerator *enu=[fArray objectEnumerator];
		id curr=[enu nextObject];
		CLLocationCoordinate2D coordinate2;
		int i=0;
		while (curr != nil){
			//NSLog(@"farray is %@",curr);
			//NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
			NSManagedObject *MO=curr;
			if ([MO valueForKey:@"lat"]!=nil) {
				person=[MO valueForKey:@"personOwnedBy"];
				Annotation *anno = [NSEntityDescription insertNewObjectForEntityForName:@"Annotation" inManagedObjectContext:context];
				
				double lat=[[MO valueForKey:@"lat"] doubleValue];
				double lon=[[MO valueForKey:@"lon"] doubleValue];
				[anno setLatitude:[NSNumber numberWithDouble:lat]];
				[anno setLongitude:[NSNumber numberWithDouble:lon]];
				[anno setIdx:[NSNumber numberWithInt:i]];
				[anno setPhotos:curr];
				self.phoName=[MO valueForKey:@"photoName"];
				//NSLog(@"latitude is %f",lat);
				coordinate2.latitude=lat;
				coordinate2.longitude=lon;
				//NSDictionary *address=[NSDictionary dictionaryWithObjectsAndKeys:@"France",@"Country",nil];
				
				//MKPlacemark *paris=[[MKPlacemark alloc]initWithCoordinate:coordinate2 addressDictionary:nil];
				anno.title=person.userName;
				anno.subtitle=self.phoName;
				
				[mapView addAnnotation:anno];
				
				
				i++;
				
				
			}
			
			
			
			curr=[enu nextObject];
			//[pool release];
		}
		
		if (![context save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving after delete", @"Error saving after delete.") 
															message:[NSString stringWithFormat:NSLocalizedString(@"Error was: %@, quitting.",@"Error was: %@, quitting."), [error localizedDescription]]
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
												  otherButtonTitles:nil];
			[alert show];
			
			exit(-1);
		}
		
		
		
		
		
		
		
	} 
	

}
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
			NSLog(@"map view loaded from initwithnibname");
    }
    return self;
}
*/
/*
-(void)checkUpdatingCoredata:(NSNotification *)noti{
	NSDictionary *dic=[noti userInfo];
	NSNumber *num=[dic valueForKey:@"update"];
	updatingCoredata=[num boolValue];
	NSLog(@"coredata is updating from notification center : this message comes from personlist view to mapview");
	//[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}
 */
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
		NSLog(@"map view loaded");
	//NSLog(@"updatingCoredata is %d",updatingCoredata);
	mapView.delegate=self;
	//updatingCoredata=NO;
	//NSNotificationCenter *notiCenter=[NSNotificationCenter defaultCenter];
	//[notiCenter addObserver:self selector:@selector(checkUpdatingCoredata:) name:@"CoredataUpdatingEvent" object:nil];
	//[self updateMap:nil];


	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark mapview controller delegate ---
/*
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
	NSLog(@"AnnotationView calling ................");
	static NSString *placemarkIdentifier = @"my annotation identifier"; 
	NSLog(@"photo name in mapview : %@",self.phoName);
	//if ([annotation isKindOfClass:[MyAnnotation class]]) {
		MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:placemarkIdentifier];
		if (annotationView == nil) { 
			annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:placemarkIdentifier]autorelease];

			//UIImage *image=[UIImage imageNamed:@"photo2.jpg"];
			CGSize size;
			CGFloat w=30.0f;
			CGFloat h=30.0f;
			size.width=w;
			size.height=h;
			UIImage *scaledImage=[self.annoImage scaleToSize:size];
			annotationView.image = scaledImage;
	   } else
		annotationView.annotation = annotation; 
		return annotationView;
	//} 
		//return nil;
}
*/
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
	//NSLog(@"This is called");
	//NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	if (run==NO) {
		idx=0;

		run=YES;
	}

	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"%K == %@",@"idx",[NSNumber numberWithInt:idx]];
	NSArray *array =[flicker fetchManagedObjectsForEntity:@"Annotation" withPredicate:predicate];
	@try {
		sharedAnnotation=[array objectAtIndex:0];
		NSLog(@"idx number of current annotation pin is : %@",[[array objectAtIndex:0] valueForKey:@"idx"]);
	}
	@catch (NSException * e) {
		NSLog(@"array is empty : error code %@",e);
	}
	@finally {
		NSLog(@"finally what will you do");
	}
	
	
	MKPinAnnotationView *pin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"parkingloc"];
	[pin setPinColor:MKPinAnnotationColorRed];
	
	// Set up the Left callout
	UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	myDetailButton.frame = CGRectMake(0, 0, 23, 23);
	myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	myDetailButton.tag=idx;
	[myDetailButton addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
	
	UIImageView *imgView= [[[UIImageView alloc] initWithFrame:CGRectMake(0,0, 50, 32)] autorelease];
	//imgView.autoresizesToImage = NO;
	imgView.contentMode = UIViewContentModeScaleAspectFit;
	photo=[sharedAnnotation photos];
	imgView.image = [UIImage imageWithData:[photo photoData]];
	pin.leftCalloutAccessoryView = imgView;
	
	
	pin.rightCalloutAccessoryView = myDetailButton;
	pin.animatesDrop = YES;
	pin.canShowCallout = YES;
	idx++;
	return pin;
	//[pool release];
}
#pragma mark -
#pragma mark custom event hanler
-(void)checkButtonTapped:(id)sender event:(UIEvent *)event{
	NSLog(@"event fired");
	NSLog(@"idx number is :%@",sender);
	UIButton *button=sender;
	NSInteger indx=button.tag;
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"%K == %@",@"idx",[NSNumber numberWithInt:indx]];
	NSArray *array =[flicker fetchManagedObjectsForEntity:@"Annotation" withPredicate:predicate];
	@try {
		sharedAnnotation=[array objectAtIndex:0];
	}
	@catch (NSException * e) {
		NSLog(@"checkbuttontapped array is empty : error code :%@",e);
	}
	@finally {
		NSLog(@"something to be done");
	}
			


	thirdVC=[[ThirdPersonViewController alloc]init];
	thirdVC.largePhoto=[sharedAnnotation photos];
	[[self navigationController] pushViewController:thirdVC animated:YES];
}
#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
  
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	mapView=nil;
	mapView.delegate=nil;
	segControl=nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[mapView release];
	[segControl release];
    [super dealloc];
}


@end
