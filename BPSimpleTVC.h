//
//  BPSimpleTVC.h
//  drunkcircle
//
//  Created by Kevin Lohman on 1/27/14.
//  Copyright (c) 2014 Logic High. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BPSimpleTVC : UITableViewController
@property (nonatomic, strong) NSArray *sections;
@end

@interface BPSimpleRow : NSObject
@property (nonatomic, strong) NSString *reuseIdentifier, *sortString;
@property (nonatomic, copy) void(^didLoadHandler)(NSIndexPath *indexPath, UITableViewCell *cell);
@property (nonatomic, strong) void(^didSelectHandler)(NSIndexPath *indexPath);
@property (nonatomic, assign) float height;
+ (BPSimpleRow *)rowWithReuseIdentifier:(NSString *)reuseIdentifier;
- (NSComparisonResult)compare:(BPSimpleRow *)row;
@end

@interface BPToggleRow : BPSimpleRow
@property (nonatomic, strong) void(^toggleHandler)(BOOL toggled);
+ (BPToggleRow *)rowWithReuseIdentifier:(NSString *)reuseIdentifier originalState:(BOOL)state toggleHandler:(void(^)(BOOL toggled))toggleHandler;
@end

@interface BPSimpleSection : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *rows;
+ (BPSimpleSection *)section;
+ (BPSimpleSection *)sectionWithTitle:(NSString *)title;
@end