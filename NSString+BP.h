//
//  NSString+BP.h
//  drunkcircle
//
//  Created by Kevin Lohman on 1/28/14.
//  Copyright (c) 2014 Logic High. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BP)
- (NSString *)stringByAppendingURLParameters:(NSDictionary *)parameters;
- (NSString *)URLEncode;
- (BOOL)isValidEmail;
@end
