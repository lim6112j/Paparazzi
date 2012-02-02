//
//  TrdCondition.h
//  Paparazzi
//
//  Created by byeong cheol lim on 11. 1. 11..
//  Copyright 2011 ocbs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TrdCondition : NSObject {
	NSCondition *condition;
	BOOL newData;
}
@property (nonatomic,retain)NSCondition *condition;
@property (nonatomic,assign)BOOL newData;
@end
