//
//  FourthViewController.h
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 11. 30..
//  Copyright 2010 ocbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "Person.h"

@interface FourthViewController : UIViewController {
	IBOutlet UILabel *label1,*label2,*label3;
	Photo *photo;
	Person *person;
}
@property(nonatomic,retain)Photo *photo;
@property(nonatomic,retain)Person *person;
@end
