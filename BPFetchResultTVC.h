//
//  BPFetchResultTVC.h
//  piratewalla
//
//  Created by Kevin Lohman on 12/22/13.
//  Copyright (c) 2013 Kevin Lohman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface BPFetchResultTVC : UITableViewController
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end
