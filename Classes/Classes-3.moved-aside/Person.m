//
//  Person.m
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 12. 9..
//  Copyright 2010 ocbs. All rights reserved.
//

#import "Person.h"


@implementation Person
@synthesize user,photos;
-(void)initData{
}
-(NSSet *)hasPhotos:(NSString*)name{
	return photos;
}
@end
