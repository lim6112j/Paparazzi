//
//  ThirdPersonViewController.m
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 11. 24..
//  Copyright 2010 ocbs. All rights reserved.
//

#import "ThirdPersonViewController.h"


@implementation ThirdPersonViewController
@synthesize largePhoto,person;

 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.

 }
 return self;
 }
 
-(void)viewDidLoad{
	[super viewDidLoad];
	self.title=@"Photo Detail";
	flicker=[FlickrFetcher sharedInstance];
	NSData *data=(NSData *)[flicker dataForPhotoID:[largePhoto path] fromFarm:[largePhoto farm] onServer:[largePhoto server] withSecret:[largePhoto secret] inFormat:FlickrFetcherPhotoFormatLarge];
	NSLog(@"image name in thirdview is : %@",[largePhoto photoName]);
	imageView.image=[UIImage imageWithData:data];
	label.text=[largePhoto photoName];
	if (self.navigationController.navigationBarHidden==YES) {
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	}
}
-(IBAction)touchedInside{
	fourthView.photo=largePhoto;
	fourthView.person=person;
	[[self navigationController]pushViewController:fourthView animated:YES];
}
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[label release];
	[imageView release];
	[fourthView release];
    [super dealloc];
}


@end
