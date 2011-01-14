//
//  NLFetchedResultsTable.m
//  -----------------------
//
//  Created by Neal Lober on 1/11/11.
//  Copyright 2011 Neal Lober. All rights reserved.
//

#import "NLFetchedResultsTable.h"

@interface NLFetchedResultsTable ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


@implementation NLFetchedResultsTable

@synthesize managedObjectContext, entityName, cellTextLabelKey;
@synthesize viewTitle, reusableCellIdentifier, sectionNameKeyPath;
@synthesize sortDescriptors, resultsCacheName, cellDetailTextLabelKey;
@synthesize fetchedResultsController;


#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
	// Since we retained all of the instance variables in this class,
	// we need to be sure to release all of them inside of dealloc.
	[fetchedResultsController release];
	[managedObjectContext release];
	[entityName release];
	[sectionNameKeyPath release];
	[sortDescriptors release];
	[viewTitle release];
	[resultsCacheName release];
	[reusableCellIdentifier release];
	[cellTextLabelKey release];
	[cellDetailTextLabelKey release];
	[super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//
	// Set the title of the view for the nav bar
	//
	[self setTitle:viewTitle];
	
    //
	// Perform the initial fetch
	//
	NSError *error = nil;
	[[self fetchedResultsController] performFetch:&error];
	ZAssert(error == nil, @"Failed to retrieve results: %@", [error localizedDescription]);
}


#pragma mark -
#pragma mark Table view datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = nil;
	sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	
	UITableViewCell *cell = nil;
	if (reusableCellIdentifier != nil)
		cell = [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];
	else
		cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@-cell-reuse-identifier", entityName]];
	

	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
									   reuseIdentifier:reusableCellIdentifier] autorelease];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
	
	if (editingStyle != UITableViewCellEditingStyleDelete) return;
	
	// Delete the managed object for the given index path
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
	
	// Save the context.
	NSError *error = nil;
	[context save:&error];
	ZAssert(error == nil, @"Error saving context: %@", [error localizedDescription]);
}

- (BOOL)tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath {
	return NO;
}


#pragma mark -
#pragma mark Table Cell Configuration

/**
 The default implementation of configureCell sets the cell's textLabel to the managed object's
 value for the key provided as cellTextLabelKey.  If there is a cellDetailTextLabelKey provided,
 then the cell's detailTextLabel is set to the managed object's value for that key as well.
 */
- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
	NSManagedObject *mo = nil;
	mo = [fetchedResultsController objectAtIndexPath:indexPath];
	[[cell textLabel] setText:[[mo valueForKey:cellTextLabelKey] description]];
	if (cellDetailTextLabelKey != nil)
		[[cell detailTextLabel] setText:[[mo valueForKey:cellDetailTextLabelKey] description]];
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
											  inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	[fetchRequest setFetchBatchSize:20];
	
	if (sortDescriptors != nil) {
		[fetchRequest setSortDescriptors:sortDescriptors];
	} else {
		[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:cellTextLabelKey 
																							   ascending:NO],nil]];
	}
	
	NSFetchedResultsController *frc = nil;
	if (resultsCacheName != nil) {
		frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
												  managedObjectContext:[self managedObjectContext] 
													sectionNameKeyPath:sectionNameKeyPath
															 cacheName:resultsCacheName];
	} else {
		frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
												  managedObjectContext:[self managedObjectContext] 
													sectionNameKeyPath:sectionNameKeyPath
															 cacheName:[NSString stringWithFormat:@"%@-frc-cache",entityName]];
	}


	[frc setDelegate:self];
	[self setFetchedResultsController:frc];
	[frc release], frc = nil;
	
	[fetchRequest release], fetchRequest = nil;
	
	return fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller {
	[[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo 
		   atIndex:(NSUInteger)sectionIndex 
	 forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] 
							withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			[[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
							withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject 
	   atIndexPath:(NSIndexPath*)indexPath 
	 forChangeType:(NSFetchedResultsChangeType)type 
	  newIndexPath:(NSIndexPath*)newIndexPath {
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
									withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
									withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[[self tableView] cellForRowAtIndexPath:indexPath]
					atIndexPath:indexPath];
			break;
		case NSFetchedResultsChangeMove:
			[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
									withRowAnimation:UITableViewRowAnimationFade];
			[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
									withRowAnimation:UITableViewRowAnimationFade];
			break;
	}  
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
	[[self tableView] endUpdates];
} 

@end

