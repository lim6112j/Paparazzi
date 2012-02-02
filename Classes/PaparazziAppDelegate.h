//
//  PaparazziAppDelegate.h
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 11. 22..
//  Copyright 2010 ocbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonListViewController.h"
#import "PhotoListViewController.h"
#import "FlickrFetcher.h"
#import "Person.h"
#import "Photo.h"
#import "MapViewController.h"
#import "sqlite3.h"
#define kFileName @"FakeData.plist"
#define sFileName @"temp.sqlite"
@interface PaparazziAppDelegate : NSObject <UIApplicationDelegate,UITabBarControllerDelegate> {
    UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	FlickrFetcher *flicker;
	NSManagedObjectContext *context;
	BOOL updatingCoredata;
	sqlite3 *database;
	IBOutlet MapViewController *mapViewCon;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) FlickrFetcher *flicker;
-(NSString *)dataFilePath;
-(void)coreDataInit;
- (NSString *)applicationDocumentsDirectory;
-(void)checkUpdatingCoredata:(NSNotification *)noti;

@end

