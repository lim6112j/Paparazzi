//
//  Annotation.h
//  Paparazzi
//
//  Created by byeong cheol lim on 11. 1. 10..
//  Copyright 2011 ocbs. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "Photo.h"

@interface Annotation :  NSManagedObject <MKAnnotation> 
{
	    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, retain) NSNumber * idx;
@property (nonatomic, retain) Photo * photos;
@property (nonatomic, readonly)    CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@end



