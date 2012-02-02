//
//  SecondPhotoViewController.h
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 11. 29..
//  Copyright 2010 ocbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThirdPhotoViewController.h"

@interface SecondPhotoViewController : UIViewController {
	IBOutlet ThirdPhotoViewController *tPVC;
}
-(IBAction)photoDetailView;
@end
