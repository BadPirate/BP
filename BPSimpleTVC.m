//
//  BPSimpleTVC.m
//  drunkcircle
//
//  Created by Kevin Lohman on 1/27/14.
//  Copyright (c) 2014 Logic High. All rights reserved.
//

#import "BPSimpleTVC.h"

@interface BPSimpleTVC ()
@end

@implementation BPSimpleRow
- (NSComparisonResult)compare:(BPSimpleRow *)row
{
    return [self.sortString compare:row.sortString];
}

+ (BPSimpleRow *)rowWithReuseIdentifier:(NSString *)reuseIdentifier
{
    BPSimpleRow *row = [[BPSimpleRow alloc] init];
    row.reuseIdentifier = reuseIdentifier;
    return row;
}
@end

@interface BPToggleRow ()
@property (nonatomic, strong) UISwitch *toggle;
@property (nonatomic, assign) BOOL initialState;
@end

@implementation BPToggleRow
+(BPToggleRow *)rowWithReuseIdentifier:(NSString *)reuseIdentifier originalState:(BOOL)state toggleHandler:(void (^)(BOOL))toggleHandler {
    BPToggleRow *row = [[BPToggleRow alloc] init];
    row.reuseIdentifier = reuseIdentifier;
    row.initialState = state;
    row.toggleHandler = toggleHandler;
    return row;
}

-(void (^)(NSIndexPath *, UITableViewCell *))didLoadHandler {
    return ^(NSIndexPath *path, UITableViewCell *cell) {
        self.toggle = [[UISwitch alloc] init];
        self.toggle.on = self.initialState;
        [self.toggle addTarget:self action:@selector(toggled:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.toggle;
        if(super.didLoadHandler) {
            super.didLoadHandler(path,cell);
        }
    };
}

-(void (^)(NSIndexPath *))didSelectHandler {
    return ^(NSIndexPath *indexPath) {
        self.toggle.on = !self.toggle.on;
        if (super.didSelectHandler) {
            super.didSelectHandler(indexPath);
        }
    };
}

- (void)toggled:(UISwitch *)toggled {
    if (self.toggleHandler) {
        self.toggleHandler(toggled.on);
    }
}
@end

@implementation BPSimpleSection
+ (BPSimpleSection *)section
{
    return [[BPSimpleSection alloc] init];
}

+ (BPSimpleSection *)sectionWithTitle:(NSString *)title
{
    BPSimpleSection *section = self.section;
    section.title = title;
    return section;
}
@end

@implementation BPSimpleTVC

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BPSimpleSection *simpleSection = self.sections[section];
    return simpleSection.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BPSimpleSection *section = self.sections[indexPath.section];
    BPSimpleRow *row = section.rows[indexPath.row];
    if(row.height <= 0)
        return tableView.rowHeight;
    return row.height;
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BPSimpleSection *section = self.sections[indexPath.section];
    BPSimpleRow *row = section.rows[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if(row.didLoadHandler)
        row.didLoadHandler(indexPath,cell);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BPSimpleSection *section = self.sections[indexPath.section];
    BPSimpleRow *row = section.rows[indexPath.row];
    
    if(row.didSelectHandler)
    {
        row.didSelectHandler(indexPath);
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    BPSimpleSection *simpleSection = self.sections[section];
    return simpleSection.title;
}
@end
