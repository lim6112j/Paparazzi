//
//  Person.h
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 12. 12..
//  Copyright 2010 ocbs. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Photo;

@interface Person :  NSManagedObject  
{
}
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSSet* photos;

@end

// coalesce these into one @interface Person (CoreDataGeneratedAccessors) section
@interface Person (CoreDataGeneratedAccessors)
- (void)addPhotosObject:(NSManagedObject *)value;
- (void)removePhotosObject:(NSManagedObject *)value;
- (void)addPhotos:(NSSet *)value;
- (void)removePhotos:(NSSet *)value;

@end




