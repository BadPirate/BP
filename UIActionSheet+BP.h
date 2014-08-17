//
//  UIActionSheet+BP.h
//  drunkcircle
//
//  Created by Kevin Lohman on 2/4/14.
//  Copyright (c) 2014 Logic High. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (BP)
+ (UIActionSheet *)actionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles completion:(void(^)(UIActionSheet *actionSheet, NSInteger buttonClicked))completionHandler;
@end
