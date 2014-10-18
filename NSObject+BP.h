//
//  NSObject+BP.h
//  Section107
//
//  Created by Kevin Lohman on 10/17/14.
//  Copyright (c) 2014 Logic High. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPKVOObserver : NSObject
- (void)remove;
@end

@interface NSObject (BP)
- (BPKVOObserver *)addBlockObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options handler:(void(^)(NSObject *object, NSDictionary *dictionary))handler;
@end
