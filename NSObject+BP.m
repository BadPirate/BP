//
//  NSObject+BP.m
//  Section107
//
//  Created by Kevin Lohman on 10/17/14.
//  Copyright (c) 2014 Logic High. All rights reserved.
//

#import "NSObject+BP.h"
#import <objc/runtime.h>

@interface BPBlockObserver : NSObject
@property (nonatomic, weak) NSObject *object;
@property (nonatomic, assign) BOOL blockKey;
@property (nonatomic, strong) NSMutableDictionary *observerBlocks;
- (void)removeKeyObserver:(BPKVOObserver *)bko;
@end

@interface BPKVOObserver ()
@property (nonatomic, weak) BPBlockObserver *blockObserver;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, copy) void (^handler)(NSObject *object, NSDictionary *dictionary);
@end

@implementation BPKVOObserver
- (BPKVOObserver *)initWithBlockObserver:(BPBlockObserver *)bo key:(NSString *)key options:(NSKeyValueObservingOptions)options handler:(void (^)(NSObject *object, NSDictionary *dictionary))handler
{
    if(!(self = [super init])) return nil;
    self.blockObserver = bo;
    self.key = key;
    self.handler = handler;
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    self.handler(object,change);
}

- (void)remove
{
    @synchronized(self.blockObserver.observerBlocks)
    {
        [self.blockObserver removeKeyObserver:self];
    }
}
@end

@implementation BPBlockObserver
- (BPBlockObserver *)initWithObject:(NSObject *)object
{
    if(!(self = [super init])) return nil;
    self.observerBlocks = [NSMutableDictionary dictionaryWithCapacity:1];
    self.object = object;
    objc_setAssociatedObject(object, &_blockKey, self, OBJC_ASSOCIATION_RETAIN);
    return self;
}

- (BOOL)isEqual:(id)object
{
    return object == self.object; // Direct pointer comparison is what we are looking for here.
}

- (BPKVOObserver *)addBlockObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options handler:(void(^)(NSObject *object, NSDictionary *dictionary))handler;
{
    BPKVOObserver *bko = nil;
    @synchronized(self.observerBlocks)
    {
        NSMutableSet *ms = self.observerBlocks[keyPath];
        if(!ms)
        {
            ms = [NSMutableSet setWithCapacity:1];
            [self.observerBlocks setObject:ms forKey:keyPath];
        }
        bko = [[BPKVOObserver alloc] initWithBlockObserver:self key:keyPath options:options handler:handler];
        [ms addObject:bko];
    }
    [self.object addObserver:bko forKeyPath:keyPath options:options context:nil];
    return bko;
}

- (void)removeKeyObserver:(BPKVOObserver *)bko
{
    @synchronized(self.observerBlocks)
    {
        NSMutableSet *ms = self.observerBlocks[bko.key];
        [self.object removeObserver:bko forKeyPath:bko.key];
        [ms removeObject:bko];
    }
}

- (void)dealloc
{
    // Only thing holding us was self.object, this means we need to deregister all the BKO stuff...
    @synchronized(self.observerBlocks)
    {
        for(NSSet *set in self.observerBlocks.allValues)
        {
            for(BPKVOObserver *bko in set.allObjects)
            {
                [bko remove];
            }
        }
    }
}
@end

@implementation NSObject (BP)
+ (BPBlockObserver *)blockObserverForObject:(NSObject *)object
{
    static NSHashTable *sBlockObservers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sBlockObservers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPersonality capacity:1];
    });
    BPBlockObserver *bo = [sBlockObservers member:object];
    if(!bo)
    {
        bo = [[BPBlockObserver alloc] initWithObject:object];
        [sBlockObservers addObject:bo];
    }
    return bo;
}

- (BPKVOObserver *)addBlockObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options handler:(void(^)(NSObject *object, NSDictionary *dictionary))handler;
{
    BPBlockObserver *bo = [BPBlockObserver blockObserverForObject:self];
    return [bo addBlockObserverForKeyPath:keyPath options:options handler:handler];
}

- (void)removeBlockObservers
{
    
}
@end
