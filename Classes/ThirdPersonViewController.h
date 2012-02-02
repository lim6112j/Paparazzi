//
//  ThirdPersonViewController.h
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 11. 24..
//  Copyright 2010 ocbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FourthViewController.h"
#import "FlickrFetcher.h"
#import "Person.h"
#import "Photo.h"

@interface ThirdPersonViewController : UIViewController {
	IBOutlet FourthViewController *fourthView;
	IBOutlet UIImageView *imageView;
	Photo *largePhoto;
	Person *person;
	IBOutlet UILabel *label;
	FlickrFetcher *flicker;
}
@property (nonatomic,retain) Photo *largePhoto;
@property (nonatomic,retain) Person *person;
-(IBAction)touchedInside;
@end
