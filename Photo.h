//
//  Photo.h
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 12. 9..
//  Copyright 2010 ocbs. All rights reserved.
//

#import <CoreData/CoreData.h>
@class Person;

@interface Photo : NSManagedObject {

}
@property(nonatomic,retain)NSString	*photoName;
@property(nonatomic,retain)Person *personOwnedBy;
@property(nonatomic,retain)NSString *path;
@property(nonatomic,retain)NSString *server;
@property (nonatomic, retain) NSString *farm;
@property(nonatomic,retain)NSString *secret;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@end