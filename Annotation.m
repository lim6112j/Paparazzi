// 
//  Annotation.m
//  Paparazzi
//
//  Created by byeong cheol lim on 11. 1. 10..
//  Copyright 2011 ocbs. All rights reserved.
//

#import "Annotation.h"


@implementation Annotation 

@dynamic idx;
@dynamic photos;
@dynamic coordinate;
@dynamic longitude;
@dynamic latitude,title,subtitle;
- (CLLocationCoordinate2D)coordinate
{
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}
@end