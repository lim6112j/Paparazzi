//
//  PaparazziAppDelegate.m
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 11. 22..
//  Copyright 2010 ocbs. All rights reserved.
//

#import "PaparazziAppDelegate.h"

@implementation PaparazziAppDelegate

@synthesize window,flicker;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	/*DB 초기화 코드 (paparazzi2 homework)
	flicker=[FlickrFetcher sharedInstance];
	if ([flicker databaseExists]) {
		NSLog(@"database exists");
	} else {
		NSLog(@"database missing need to be set");
		if ([self dataFilePath]) {
//			NSLog(@"datafile fakedata.plist exists");
			[self coreDataInit];
		}
	}
	 */	
	NSNotificationCenter *notiCenter=[NSNotificationCenter defaultCenter];
	[notiCenter addObserver:self selector:@selector(checkUpdatingCoredata:) name:@"CoredataUpdatingEvent" object:nil];
	tabBarController.delegate=self;
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
    
    return YES;
}
-(void)coreDataInit{
	context=[flicker managedObjectContext];
	//Get path to copy the Bundle to the Documents directory...
	NSString *rootPath = [self applicationDocumentsDirectory];
	NSString *plistPath = [rootPath stringByAppendingPathComponent:@"FakeData.plist"];
	
	//Pull the data from the Bundle object in the Resources directory...
	NSFileManager *defaultFile = [NSFileManager defaultManager];
	BOOL isInstalled = [defaultFile fileExistsAtPath :plistPath];
	
	NSArray *plistData = [NSArray arrayWithContentsOfFile :plistPath];
	
	if(isInstalled == NO)
	{		
//		NSLog(@"Initial installation: retrieve and copy FakeData.plist from Main Bundle");
		
		NSString *bundlePath = [[NSBundle mainBundle] pathForResource :@"FakeData" ofType:@"plist"];
		plistData = [NSArray arrayWithContentsOfFile :bundlePath];
		
		if(plistData)
		{
			[plistData writeToFile :plistPath atomically:YES];
			//OR... [defaultFile copyItemAtPath:bundlePath toPath:plistPath error:&errorDesc];
		}		
	}
	
	//Process plistData to store in Photo and Person objects...
	NSEnumerator *enumr = [plistData objectEnumerator];
	id curr = [enumr nextObject];
	NSMutableArray *names = [[NSMutableArray alloc] init];
	
	while (curr != nil)
	{
		Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
		[photo setPhotoName:[curr objectForKey:@"name"]];
		NSLog(@"curr objectForkey : name is : %@",[curr objectForKey:@"name"]);
		NSLog(@"photo.photoname is : %@",[photo photoName]);
		[photo setPath:[curr objectForKey:@"path"]];
		
		//See if the name has already been set for a Person object...
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ IN %@", [curr objectForKey:@"user"], names];
		BOOL doesExist = [predicate evaluateWithObject :curr];
		
		if (doesExist == NO)
		{				
			Person *person = [NSEntityDescription insertNewObjectForEntityForName :@"Person" inManagedObjectContext:context];
			[person setUserName:[curr objectForKey:@"user"]];
			[person addPhotosObject:photo];
			[photo setPersonOwnedBy:person];
			NSLog(@"Person OBJECT: %@", person);
			[names addObject :[curr objectForKey :@"user"]];
		}
		else 
		{
			NSArray *objectArray = [flicker fetchManagedObjectsForEntity :@"Person" withPredicate:predicate];
			Person *person = [objectArray objectAtIndex:0];
			[photo setPersonOwnedBy:person];
			//[objectArray release]; 이넘 땜에 첫 기동시 어플이 다운되는 현상이 있었음.
		}
		curr = [enumr nextObject];
	}
	[names release];
	NSError *error;
	if (![context save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving after delete", @"Error saving after delete.") 
														message:[NSString stringWithFormat:NSLocalizedString(@"Error was: %@, quitting.",@"Error was: %@, quitting."), [error localizedDescription]]
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
											  otherButtonTitles:nil];
		[alert show];
		
		exit(-1);
	}
/*
	context=[flicker managedObjectContext];
	NSArray *objects= [flicker fetchManagedObjectsForEntity:@"Dic" withPredicate:nil];
	if (objects==nil) {
		NSLog(@"there is error in coredata");
	}
	if ([objects count]>0) {
		//NSLog(@"objects count :[%d]",[objects count]);
	//	MODic=[objects objectAtIndex:0];
	} else {
		//NSLog(@"objects count :[%d]",[objects count]);
#pragma mark -
#pragma mark plist file parsing.
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *plistPath = [bundle pathForResource:@"FakeData" ofType:@"plist"];
		NSArray *array = [NSArray  arrayWithContentsOfFile:plistPath];
		NSEnumerator *obj=[array objectEnumerator];
		id curEnum=[obj nextObject];
		NSMutableArray *names = [[NSMutableArray alloc] init];
		while (curEnum != nil) {
			Photo *photoMO=[NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
			photoMO.photoName=[curEnum objectForKey:@"name"];
			photoMO.path=[curEnum objectForKey:@"path"];
			NSPredicate *predicate=[NSPredicate predicateWithFormat:@"%@ IN %@",[curEnum objectForKey:@"user"],names];
			BOOL exists=[predicate evaluateWithObject:curEnum];
			if (exists == NO)
			{				
				Person *personMO = [NSEntityDescription insertNewObjectForEntityForName :@"Person" inManagedObjectContext:context];
				
				[personMO setUserName:[curEnum objectForKey:@"user"]];
				[personMO addPhotosObject:photoMO];
				[photoMO setPersonOwnedBy:personMO];
				NSLog(@"Person OBJECT: %@", personMO);
				[names addObject :[curEnum objectForKey :@"user"]];
			}
			else 
			{
				NSArray *objectArray = [flicker fetchManagedObjectsForEntity :@"Person" withPredicate:predicate];
				Person *personMO = [objectArray objectAtIndex:0];
				[photoMO setPersonOwnedBy:personMO];
				[objectArray release];
			}
			curEnum = [obj nextObject];
		}
			[names release];


		
	
	} 
 예전 버전
	 NSError *error;
	 for (int i=0; i<[array count]; i++) {
	 NSManagedObject *MODic;
	 MODic=[NSEntityDescription insertNewObjectForEntityForName:@"Dic" inManagedObjectContext:context];
	 
	 NSDictionary *dic=[[NSDictionary alloc] initWithDictionary:[array objectAtIndex:i]];
	 //[MOReal setValue:MODic forKey:@"dic"];
	 [MODic setValue:[dic objectForKey:@"path"] forKey:@"path"];
	 [MODic setValue:[dic objectForKey:@"name"] forKey:@"name"];
	 [MODic setValue:[dic objectForKey:@"user"] forKey:@"user"];
	 [context save:&error];
	 NSLog(@"[%d] Data from Fakedata.plist transfered to Coredata and sqlite.",[array count]);
	 NSLog(@"%@ is inserted in path key",[MODic valueForKey:@"path"]);
	 NSLog(@"%@ is inserted in user key",[MODic valueForKey:@"user"]);
	 NSLog(@"%@ is inserted in name key",[MODic valueForKey:@"name"]);
	 [dic release];
	 }
	 */
}
- (NSString *)applicationDocumentsDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

-(NSString *)dataFilePath{
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory=[paths objectAtIndex:0];
	//NSLog(@"documentsDirectory is %@",[documentsDirectory stringByAppendingPathComponent:kFileName]);
	return [documentsDirectory stringByAppendingPathComponent:kFileName];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
}
- (void)tabBarController:(UITabBarController *)tabBarController2 didSelectViewController:(UIViewController *)viewController{
	NSInteger num= tabBarController2.selectedIndex;
	if (num==2) {
					NSLog(@"selected view is MapView");

		[mapViewCon updateMap:[NSNumber numberWithBool:updatingCoredata]];
	}

}
-(void)checkUpdatingCoredata:(NSNotification *)noti{
	NSDictionary *dic=[noti userInfo];
	NSNumber *num=[dic valueForKey:@"update"];
	updatingCoredata=[num boolValue];
	NSLog(@"coredata is updating from notification center : this message comes from personlist view to mapview updatingCoredata is %d",updatingCoredata);
	//[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}
#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[tabBarController release];
    [window release];
    [super dealloc];
}


@end
