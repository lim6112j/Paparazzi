//
//  PhotoListViewController.h
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 11. 22..
//  Copyright 2010 ocbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondPhotoViewController.h"

@interface PhotoListViewController : UIViewController {
	SecondPhotoViewController *sPVC;
}
-(IBAction)photoDetailView;
@end
