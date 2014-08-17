//
//  UIActionSheet+BP.m
//  drunkcircle
//
//  Created by Kevin Lohman on 2/4/14.
//  Copyright (c) 2014 Logic High. All rights reserved.
//

#import "UIActionSheet+BP.h"

@interface BPActionSheet : UIActionSheet <UIActionSheetDelegate>
@property (nonatomic, copy) void(^completionHandler)(UIActionSheet *actionSheet, NSInteger buttonClicked);
@end

@implementation UIActionSheet (BP)
+ (UIActionSheet *)actionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles completion:(void(^)(UIActionSheet *actionSheet, NSInteger buttonClicked))completionHandler
{
    BPActionSheet *actionSheet = [[BPActionSheet alloc] initWithTitle:title
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    NSUInteger buttonIndex = 0;
    for(NSString *title in otherButtonTitles)
    {
        [actionSheet addButtonWithTitle:title];
        buttonIndex++;
    }
    if(cancelButtonTitle)
    {
        [actionSheet addButtonWithTitle:cancelButtonTitle];
        actionSheet.cancelButtonIndex = buttonIndex;
        buttonIndex++;
    }
    if(destructiveButtonTitle)
    {
        [actionSheet addButtonWithTitle:destructiveButtonTitle];
        actionSheet.destructiveButtonIndex = buttonIndex;
    }
    actionSheet.completionHandler = completionHandler;
    actionSheet.delegate = actionSheet;

    return actionSheet;
}
@end

@implementation BPActionSheet
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.completionHandler)
        self.completionHandler(self,buttonIndex);
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    if(self.completionHandler)
        self.completionHandler(self,self.cancelButtonIndex);
}
@end
