//
//  NSString+BP.m
//  drunkcircle
//
//  Created by Kevin Lohman on 1/28/14.
//  Copyright (c) 2014 Logic High. All rights reserved.
//

#import "NSString+BP.h"

@implementation NSString (BP)
// http://stackoverflow.com/a/8088484/285694
- (NSString *)URLEncode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    NSInteger sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (NSString *)stringByAppendingURLParameters:(NSDictionary *)parameters
{
    if(parameters.count == 0)
        return self;
    
    NSString *result = [self stringByAppendingString:@"?"];
    NSArray *keyArray = [parameters allKeys];
    NSUInteger i = 0;
    while(true)
    {
        NSString *key = keyArray[i];
        NSString *value = parameters[key];
        i++;
        if(i == keyArray.count)
        {
            result = [result stringByAppendingFormat:@"%@=%@",[key URLEncode],[value.description URLEncode]];
            break;
        }
        else
        {
            result = [result stringByAppendingFormat:@"%@=%@&",[key URLEncode],[value.description URLEncode]];
        }
    }
    return result;
}

- (BOOL)isValidEmail
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}
@end
