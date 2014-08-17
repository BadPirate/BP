//
//  BPFetchResultTVC.m
//  piratewalla
//
//  Created by Kevin Lohman on 12/22/13.
//  Copyright (c) 2013 Kevin Lohman. All rights reserved.
//

#import "BPFetchResultTVC.h"

@interface BPFetchResultTVC () <NSFetchedResultsControllerDelegate>
@property (nonatomic, assign) BOOL loaded;
@end

@implementation BPFetchResultTVC

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    [self willChangeValueForKey:@"fetchedResultsController"];
    self.fetchedResultsController.delegate = nil;
    _fetchedResultsController = fetchedResultsController;
    [self didChangeValueForKey:@"fetchedResultsController"];
    
    self.fetchedResultsController.delegate = self;
    if(self.loaded)
        [self.fetchedResultsController performFetch:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loaded = YES;
    [self.fetchedResultsController.managedObjectContext performBlockAndWait:^{
        [self.fetchedResultsController performFetch:nil];
    }];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.fetchedResultsController.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [(id <NSFetchedResultsSectionInfo>)self.fetchedResultsController.sections[section] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [(id <NSFetchedResultsSectionInfo>)self.fetchedResultsController.sections[section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[indexPath.section];
    NSManagedObject *object = [sectionInfo objects][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(object.class) forIndexPath:indexPath];
    if([cell respondsToSelector:@selector(setObject:)])
    {
        [cell performSelector:@selector(setObject:) withObject:object];
    }
    return cell;
}

- (void)setObject:(NSManagedObject *)object
{
    // Do nothing, gets rid of warning.
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if(![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self controllerWillChangeContent:controller];
        });
        return;
    }
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if(![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
        });
        return;
    }
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            // should be KVO
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if(![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self controller:controller didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
        });
        return;
    }
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    if(![NSThread isMainThread])
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self controllerDidChangeContent:controller];
        });
        return;
    }
    [self.tableView endUpdates];
}

@end
