//
//  SecondPersonViewController.m
//  Paparazzi
//
//  Created by byeong cheol lim on 10. 11. 23..
//  Copyright 2010 ocbs. All rights reserved.
//

#import "SecondPersonViewController.h"


@implementation SecondPersonViewController
@synthesize person,photo;
@synthesize sharedContext=_sharedContext;
@synthesize fetchedResultsController=_fetchedResultsController;
-(void)viewDidLoad{
	[super viewDidLoad];
	self.title=@"Person Detail";
	
	[NSFetchedResultsController deleteCacheWithName:@"Root"];
	flicker=[FlickrFetcher sharedInstance];
	self.sharedContext=[flicker managedObjectContext];
	[self retainCountLog:self.sharedContext];
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"personOwnedBy=%@",person];
	self.fetchedResultsController=[flicker fetchedResultsControllerForEntity:@"Photo" withPredicate:predicate];
	
	_fetchedResultsController.delegate=self;//이라인이 있어야 줄 삭제시 테이블이 즉시 업데이트 된다.
	NSError *error;
	
	if (![_fetchedResultsController performFetch:&error]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error loading data", @"Error loading data") 
														message:[NSString stringWithFormat:@"Error was: %@, quitting.", [error localizedDescription]]
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
											  otherButtonTitles:nil];
		[alert show];
		
	}
	/*
	[NSFetchedResultsController deleteCacheWithName:@"Root"];
	FlickrFetcher *flickrFetcher = [FlickrFetcher sharedInstance];
	sharedContext = [flickrFetcher managedObjectContext];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:sharedContext];
	[request setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"photoName" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors :sortDescriptors];
	[request setFetchBatchSize :20];
	[sortDescriptors release];
	NSLog(@"secondview's person name is : %@",[person userName]);
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personOwnedBy=%@", person];
	[request setPredicate :predicate];
	
	fetchedResultsController = [[NSFetchedResultsController alloc] 
								initWithFetchRequest:request 
								managedObjectContext:sharedContext 
								sectionNameKeyPath:nil 
								cacheName:@"Root"];
	
	[request release];

	NSError *error;
	[fetchedResultsController performFetch:&error];
	 	*/
}

#pragma mark -
#pragma mark Initialization

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 self = [super initWithStyle:style];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */


#pragma mark -
#pragma mark View lifecycle

/*
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 }
 */

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
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	NSInteger size = [[self.fetchedResultsController sections] count];
	
	if (size == 0) {
		size = 1;
	}
    return size;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSArray *sections = [self.fetchedResultsController sections];
	NSInteger count = 0;
	
	if ([sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
		count = [sectionInfo numberOfObjects];
	}
	return count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    //Set up the cell (DON'T EVER RELEASE an object - Photo - from fetchedResultsController!)...
	photo = [self.fetchedResultsController objectAtIndexPath :indexPath];
	cell.imageView.image = [UIImage imageWithData:[photo photoData]];
	cell.textLabel.text = [photo photoName];
		
    return cell;
	 
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		self.photo=[self.fetchedResultsController objectAtIndexPath:indexPath];
		[self.sharedContext deleteObject:self.photo];
		NSError *error;
		if (![self.sharedContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving after delete", @"Error saving after delete.") 
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"Error was: %@, quitting.",@"Error was: %@, quitting."), [error localizedDescription]]
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
                                                  otherButtonTitles:nil];
            [alert show];
			
			exit(-1);
		}
	}   
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    
	thirdView = [[ThirdPersonViewController alloc] initWithNibName:@"ThirdPersonViewController" bundle:nil];
	photo = [self.fetchedResultsController objectAtIndexPath :indexPath];
	thirdView.person=person;
	thirdView.largePhoto=photo;
	NSLog(@"from secondview , largephoto name is %@",[photo photoName]);
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:thirdView animated:YES];
	 [thirdView release];
	 
}
#pragma mark -
#pragma mark Fetched results controller delegate



- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"table will change");
    [self.tableView beginUpdates];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"table did change");
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
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths: [NSArray arrayWithObject:newIndexPath]
                                      withRowAnimation: UITableViewRowAnimationRight];
                
            }
            else {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationFade];
            }
			break;
        default:
			break;
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[thirdView release];
    [super dealloc];
}

	 -(void)retainCountLog:(id)obj{
		 NSLog(@"------------------------------------------------------------------------------");
		 NSLog(@"%@'s retain count is : %d",[obj description],[obj retainCount]);
	 }
@end

