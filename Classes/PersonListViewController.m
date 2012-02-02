//
//  PersonListViewController.m
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 11. 22..
//  Copyright 2010 ocbs. All rights reserved.
//

#import "PersonListViewController.h"


@implementation PersonListViewController
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize context=_context;
@synthesize person,photo,flicker,inputName,condition;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/
-(IBAction)addPerson{
	AddModalViewController *mVC=[[AddModalViewController alloc]initWithNibName:@"AddModalViewController" bundle:nil];
	modalView=mVC;
	[self presentModalViewController:modalView animated:YES];
	mVC.textField.delegate=self;
	[mVC release];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	self.inputName=textField.text;
	NSLog(@"textfield data transfered to personlistViewController is : %@", self.inputName);
	[NSThread detachNewThreadSelector:@selector(insertPerson:) toTarget:self withObject:self.inputName];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	self.inputName=textField.text;
	[modalView dismissModalViewControllerAnimated:YES];
	return YES;
}

#pragma mark -
#pragma mark 디폴트 user를 왼쪽 상단 버튼으로 추가
-(IBAction)defaultPerson{
	NSArray *array=[NSArray arrayWithObjects:@"warzauwynn",nil];
	//NSArray *array=[NSArray arrayWithObjects:@"warzauwynn",@"tiquetonne2067",@"jonomillin",nil];
	NSEnumerator *enu=[array objectEnumerator];
	id curr=[enu nextObject];
	while (curr != nil) {
		self.inputName=curr;
		//[self insertPerson:self.inputName];
		[NSThread detachNewThreadSelector:@selector(insertPerson:) toTarget:self withObject:self.inputName];
		curr=[enu nextObject];
	}
}
#pragma mark -
#pragma mark UIActivityIndicator를 추가함-thread로 돌려야함. 
-(void)startSpinner
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CGRect frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
	av = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	av.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
	[av setCenter:CGPointMake(160.0f, 208.0f)];
	[av hidesWhenStopped];
	[self.tableView addSubview:av];
	[av startAnimating];
	[pool release];
}

#pragma mark -
#pragma mark 입력된 사용자를 coredata에 추가하는 함수.
-(void)insertPerson:(id)object{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	NSThread *spinThread=[[NSThread alloc] initWithTarget:self selector:@selector(startSpinner) object:nil];
    [spinThread start];
	updateCoreData=YES;
	NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:updateCoreData] forKey:@"update"];
	NSNotificationCenter *notiCenter=[NSNotificationCenter defaultCenter];
	[notiCenter postNotificationName:@"CoredataUpdatingEvent" object:self userInfo:dic];
	/* tableView를 꺼졌다 켜는 소스
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[self.tableView setAlpha:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	[self.tableView setHidden:NO];
	[self.tableView setAlpha:1];
	[UIView commitAnimations];
*/


	NSArray *array=[flicker photosForUser:object];
	NSLog(@"%@ is the array",array);
	//Process plistData to store in Photo and Person objects...
	NSEnumerator *enumr = [array objectEnumerator];
	id curr = [enumr nextObject];
	NSMutableArray *names = [[NSMutableArray alloc] init];
	
	while (curr != nil)
	{
		Photo *pho = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:_context];
		[pho setPhotoName:[curr objectForKey:@"title"]];
	//	NSLog(@"curr objectForkey : name is : %@",[curr objectForKey:@"title"]);
	//	NSLog(@"photo.photoname is : %@",[pho photoName]);
		[pho setPath:[curr objectForKey:@"id"]];
	//	NSLog(@"farm number is %@",[curr objectForKey:@"farm"]);
		NSString *string=[NSString stringWithFormat:@"%@",[curr objectForKey:@"farm"]];
		[pho setFarm:string];
		[pho setServer:[curr objectForKey:@"server"]];
		[pho setSecret:[curr objectForKey:@"secret"]];
		NSDictionary *dic= [flicker locationForPhotoID:[curr objectForKey:@"id"]];
		double lat,lon;
		if (dic!=NULL) {
			lat=[[dic valueForKey:@"latitude"] doubleValue];
			lon=[[dic valueForKey:@"longitude"] doubleValue];
			[pho setLat:[NSNumber numberWithDouble:lat]];
			[pho setLon:[NSNumber numberWithDouble:lon]];
		}


		NSData *data=(NSData *)[flicker dataForPhotoID:[pho path] fromFarm:[curr objectForKey:@"farm"] onServer:[curr objectForKey:@"server"] withSecret:[curr objectForKey:@"secret"] inFormat:FlickrFetcherPhotoFormatSquare];
		[pho setPhotoData:data];
		
		//See if the name has already been set for a Person object...
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ IN %@", [curr objectForKey:@"owner"], names];
		BOOL doesExist = [predicate evaluateWithObject :curr];
		
		if (doesExist == NO)
		{				
			Person *per = [NSEntityDescription insertNewObjectForEntityForName :@"Person" inManagedObjectContext:_context];
			[per setUserName:self.inputName];
			[per setOwner:[curr objectForKey:@"owner"]];
			[per addPhotosObject:pho];
			[pho setPersonOwnedBy:per];
		//	NSLog(@"Person OBJECT: %@", per);
			[names addObject :[curr objectForKey :@"owner"]];
		}
		else 
		{
			NSPredicate *pred=[NSPredicate predicateWithFormat:@"%K LIKE %@",@"userName",self.inputName];
			NSArray *objectArray = [flicker fetchManagedObjectsForEntity :@"Person" withPredicate:pred];
			NSLog(@"person exists, same owner is %@",objectArray);
			Person *per = [objectArray objectAtIndex:0];
			NSLog(@"selected managedobject is : %@",per);
			[pho setPersonOwnedBy:per];
			//[objectArray release]; 이넘 땜에 첫 기동시 어플이 다운되는 현상이 있었음.
		}
		curr = [enumr nextObject];
	}
	[names release];

	NSError *error;
	[_fetchedResultsController performFetch:&error];
	if (![_context save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving after delete", @"Error saving after delete.") 
														message:[NSString stringWithFormat:NSLocalizedString(@"Error was: %@, quitting.",@"Error was: %@, quitting."), [error localizedDescription]]
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
											  otherButtonTitles:nil];
		[alert show];
		
		exit(-1);
	}
	
	[self.tableView reloadData];	
	//[mapViewController.view setNeedsDisplay]; //이게 왜 필요했는지 모르겠음.
	[self performSelectorOnMainThread:@selector(threadDone:) withObject:self.inputName waitUntilDone:NO];
	updateCoreData=NO;
	[dic setValue:[NSNumber numberWithBool:updateCoreData] forKey:@"update"];
	[notiCenter postNotificationName:@"CoredataUpdatingEvent" object:self userInfo:dic];
	[av stopAnimating];
    [spinThread release];
	[pool release];

}
-(void)threadDone:(id)object{
	NSLog(@"thread is finished");
}



#pragma mark -
#pragma mark Initialization

//Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.


#pragma mark -
#pragma mark View lifecycle



 - (void)viewDidLoad {
	 [super viewDidLoad];
	 self.title=@"PersonList";
	 NSError *error;
	 FlickrFetcher *f= [FlickrFetcher sharedInstance];
	 self.flicker=f;
	 [f release];

	 NSManagedObjectContext *c=[flicker managedObjectContext];
	 self.context = c;
	 [c release];

	 //-- Optionally use the below line instead of the rest of the lines in the IF statement --/
	 NSFetchedResultsController *Nsf=[flicker fetchedResultsControllerForEntity:@"Person" withPredicate:nil];
	 self.fetchedResultsController = Nsf;
	 [Nsf release]; //FLickrfetcher.m에 보면 return autorelease가 사용되었으므로 Nsf는 자동 dealloc되므로 또다시 release해 줄 필요 없다
	 //_fetchedResultsController.delegate=self;//이라인이 있어야 줄 삭제시 테이블이 즉시 업데이트 된다.
	 
	 
	 if (![_fetchedResultsController performFetch:&error]) {
		 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error loading data", @"Error loading data") 
														 message:[NSString stringWithFormat:@"Error was: %@, quitting.", [error localizedDescription]]
														delegate:self 
											   cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
											   otherButtonTitles:nil];
		 [alert show];
		 
	 }

	 // Save the context.
	 //	 [self retainCountLog:_fetchedResultsController];
//	 [self retainCountLog:_context];
	// NSLog(@"retain number of context : %d when loading the view",[_context retainCount]);
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 }
 

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSLog(@"in the numberofsections in tableview");
	[self retainCountLog:self.fetchedResultsController];
	NSUInteger count = [[self.fetchedResultsController sections] count];
	NSLog(@"섹션의 갯수는 %d",count);
	if (count == 0) {
		count = 1;
		NSLog(@"sections has 0 section something wrong");
	}
	
	return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSLog(@"section is : %d",section);
    NSArray *sections = [self.fetchedResultsController sections];
	NSLog(@"sections array is : %@",sections);
    NSUInteger count = 0;
    if ([sections count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    }
	NSLog(@"row 갯수는 %d",count);
    return count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] 
				 initWithStyle:UITableViewCellStyleSubtitle 
				 reuseIdentifier:CellIdentifier] 
				autorelease];
    }
    
    // Set up the cell...

	person = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if (person==NULL) {
		NSLog(@"person data is null");
	}
	cell.detailTextLabel.text = [person owner];
	cell.textLabel.text=[person userName];
	
	//More elegant way of the above enumeration, but with a random selection...
	NSSet *photoSet = [person photos];
	Photo *photoObj = [photoSet anyObject];
	NSLog(@"person owner is %@",[person owner] );

	cell.imageView.image = [UIImage imageWithData:[photoObj photoData]];
	//NSLog(@"image path is : %@",[image path]);

	
	
    return cell; //[cell autorelease]되어있어서 문제가 생겼었음. 이전버전과 비교.
	
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */




/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate
- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//아래 주석 처리 부분은 첫 줄을 선택되지 않도록하여 셀선택이 버튼 기능을 못하게 한다.
//	NSInteger row = [indexPath row];
//	if (row == 0)
//		return nil;
	
	return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	sPVC = [[SecondPersonViewController alloc] initWithNibName:@"SecondPersonViewController" bundle:nil];
	person = [self.fetchedResultsController objectAtIndexPath:indexPath];
	sPVC.person=person;
	NSLog(@"From personlistview : secondview's person name is : %@",[person userName]);
	[[self navigationController] pushViewController:sPVC animated:YES];
	NSLog(@"push second view");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSError *error;
	if (editingStyle == UITableViewCellEditingStyleDelete) {
	// Delete the managed object for the given index path
		[self retainCountLog:_context];
		[_context deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
		[_fetchedResultsController performFetch:&error];
	// Save the context.

		if (![_context save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
		NSLog(@"after delete and save the context");
		//[self retainCountLog:_fetchedResultsController];
		[self.tableView beginUpdates];	
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath ] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];

	}   

}
/*
#pragma mark -
#pragma mark Fetched results controller delegate
 
 - (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	 [self.tableView beginUpdates];
 }
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	 [self.tableView endUpdates];
 }
 - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
 switch(type) {
	 case NSFetchedResultsChangeInsert:
		 [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		 break;
		 
	 case NSFetchedResultsChangeDelete:
		 [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		 break;
		 
	 case NSFetchedResultsChangeUpdate: {
		 NSString *sectionKeyPath = [controller sectionNameKeyPath];
		 if (sectionKeyPath == nil)
		 break;
		 NSManagedObject *changedObject = [controller objectAtIndexPath:indexPath];
		 NSArray *keyParts = [sectionKeyPath componentsSeparatedByString:@"."];
		 id currentKeyValue = [changedObject valueForKeyPath:sectionKeyPath];
		 for (int i = 0; i < [keyParts count] - 1; i++) {
		 NSString *onePart = [keyParts objectAtIndex:i];
		 changedObject = [changedObject valueForKey:onePart];
		 }
		 sectionKeyPath = [keyParts lastObject];
		 NSDictionary *committedValues = [changedObject committedValuesForKeys:nil];
		 
		 if ([[committedValues valueForKeyPath:sectionKeyPath] isEqual:currentKeyValue])
		 break;
		 
		 NSUInteger tableSectionCount = [self.tableView numberOfSections];
		 NSUInteger frcSectionCount = [[controller sections] count];
		 if (tableSectionCount != frcSectionCount) {
		 // Need to insert a section
		 NSArray *sections = controller.sections;
		 NSInteger newSectionLocation = -1;
		 for (id oneSection in sections) {
		 NSString *sectionName = [oneSection name];
		 if ([currentKeyValue isEqual:sectionName]) {
		 newSectionLocation = [sections indexOfObject:oneSection];
		 break;
		 }
		 }
		 if (newSectionLocation == -1)
		 return; // uh oh
		 
		 if (!((newSectionLocation == 0) && (tableSectionCount == 1) && ([self.tableView numberOfRowsInSection:0] == 0)))
		 [self.tableView insertSections:[NSIndexSet indexSetWithIndex:newSectionLocation] withRowAnimation:UITableViewRowAnimationFade];
		 NSUInteger indices[2] = {newSectionLocation, 0};
		 newIndexPath = [[[NSIndexPath alloc] initWithIndexes:indices length:2] autorelease];
		 }
		 }
		 
	 case NSFetchedResultsChangeMove:
		 if (newIndexPath != nil) {
		 
		 NSUInteger tableSectionCount = [self.tableView numberOfSections];
		 NSUInteger frcSectionCount = [[controller sections] count];
		 if (frcSectionCount > tableSectionCount) 
			 [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[newIndexPath section]] withRowAnimation:UITableViewRowAnimationNone];
		 else if (frcSectionCount < tableSectionCount && tableSectionCount > 1)
			 [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationNone];
		 
		 
			 [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			 [self.tableView insertRowsAtIndexPaths: [NSArray arrayWithObject:newIndexPath] withRowAnimation: UITableViewRowAnimationRight];		 
		 }
		 else {
			 [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationFade];
		 }
		 break;
		 default:
		 break;
		 }
 }
 - (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
 switch(type) {
 
 case NSFetchedResultsChangeInsert:
 if (!((sectionIndex == 0) && ([self.tableView numberOfSections] == 1)))
 [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
 break;
 case NSFetchedResultsChangeDelete:
 if (!((sectionIndex == 0) && ([self.tableView numberOfSections] == 1) ))
 [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
 break;
 case NSFetchedResultsChangeMove:
 break;
 case NSFetchedResultsChangeUpdate: 
 break;
 default:
 break;
 }
 }
 
 */

	#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

/*
- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}
*/

- (void)dealloc {
//	[_fetchedResultsController release];
//	[_context release];
	[sPVC release];
//	[flicker release];
    [super dealloc];
}

-(void)retainCountLog:(id)obj{
	NSLog(@"------------------------------------------------------------------------------");
	NSLog(@"%@'s retain count is : %d",[obj description],[obj retainCount]);
}

@end
