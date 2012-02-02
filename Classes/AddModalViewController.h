//
//  AddModalViewController.h
//  Paparazzi
//
//  Created by byeong cheol lim on 11. 1. 3..
//  Copyright 2011 ocbs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddModalViewController : UIViewController {
	IBOutlet UITextField *textField;
}
@property (nonatomic,retain) UITextField *textField;

-(IBAction)backgroundTab;
@end
