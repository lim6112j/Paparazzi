//
//  Person.h
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 12. 9..
//  Copyright 2010 ocbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrFetcher.h"

@interface Person : NSObject {
	FlickrFetcher *flicker;
	NSString *user;
	NSSet *photos;
}
@property (nonatomic, retain) NSString *user;
@property (nonatomic,retain) NSSet *photos;
-(void)initData;
-(NSSet *)hasPhotos:(NSString*)name;
@end
