//
//  NLFetchedResultsTable.h
//  -----------------------
//
//  Created by Neal Lober on 1/11/11.
//  Copyright 2011 Neal Lober. All rights reserved.
//
//  This class was created to allow you to quickly create UITableViewcontrollers that are backed by
//  an NSFetchedResultsController.  Much of this code was adapted from Marcus Zarra's article
//  "Touching The Core," published in the January 2010 article of PragPub magazine as well as the
//  accompanying Feed-Reader project available on GitHub.
//  See: http://pragprog.com/magazines/2010-01/touching-the-core
//  And See: https://github.com/mzarra/Feed-Reader
//

#import <UIKit/UIKit.h>


@interface NLFetchedResultsTable : UITableViewController <NSFetchedResultsControllerDelegate> {
	
	// Variables that are required to be set for basic functionality
	NSManagedObjectContext		*managedObjectContext;			// the managed object context in which to work
	NSString					*entityName;					// the name of the entity to display
	NSString					*cellTextLabelKey;				// the key to use for the cells' textLabel.text

	// Variables that can be optionally set to add functionality to your NLFetchedResultsTable
	NSString					*viewTitle;						// the title to use for the view
	NSString					*reusableCellIdentifier;			// a reusableCellIdentifier for the UITableViewCell
	NSString					*sectionNameKeyPath;				// key path to use for sections in the table view
	NSArray						*sortDescriptors;				// an array of sort descriptors
	NSString					*resultsCacheName;				// manually specify a name to use for the frc's results cache
	NSString					*cellDetailTextLabelKey;			// a key to use for the cells' detailTextLabel.text
	
	// Internally-used fetchedResultsController
	NSFetchedResultsController	*fetchedResultsController;	
	
}

// Variables that are required to be set for basic functionality
@property (nonatomic, retain) NSManagedObjectContext	 	 *managedObjectContext;
@property (nonatomic, retain) NSString					 *entityName;
@property (nonatomic, retain) NSString					 *cellTextLabelKey;

// Variables that can be optionally set to add functionality to your NLFetchedResultsTable
@property (nonatomic, retain) NSString					 *viewTitle;
@property (nonatomic, retain) NSString					 *reusableCellIdentifier;
@property (nonatomic, retain) NSString					 *sectionNameKeyPath;
@property (nonatomic, retain) NSArray					 *sortDescriptors;
@property (nonatomic, retain) NSString					 *resultsCacheName;
@property (nonatomic, retain) NSString					 *cellDetailTextLabelKey;

// Internally-used fetchedResultsController
@property (nonatomic, retain) NSFetchedResultsController	 *fetchedResultsController;

@end
