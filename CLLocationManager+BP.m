//
//  CLLocationManager+BP.m
//  drunkcircle
//
//  Created by Kevin Lohman on 8/17/14.
//  Copyright (c) 2014 Logic High. All rights reserved.
//

#import "CLLocationManager+BP.h"
#import <CoreLocation/CoreLocation.h>

@class BPLocationDelegate;

static BPLocationDelegate *sLocationDelegate;

@interface BPLocationDelegate : NSObject <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) NSArray *completionHandlers;
- (id)initWithCompletionHandler:(BPLocationHandler)completionHandler;

- (void)completeWithLocation:(CLLocation *)location error:(NSError *)error;
- (void)start;
@end

@implementation BPLocationDelegate
- (id)initWithCompletionHandler:(BPLocationHandler)completionHandler
{
    self = [super init];
    self.completionHandlers = @[completionHandler];
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self completeWithLocation:[locations objectAtIndex:0] error:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self completeWithLocation:nil error:error];
}

- (void)completeWithLocation:(CLLocation *)location error:(NSError *)error
{
    self.manager.delegate = nil;
    [self.manager stopUpdatingLocation];
    
    for(BPLocationHandler handler in self.completionHandlers)
    {
        handler(location,error);
    }
    sLocationDelegate = nil;
}

- (void)start
{
    if(self.manager) return;
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    [self.manager startUpdatingLocation];
}
@end


@implementation CLLocationManager (BP)

 + (void)getCurrentLocationReason:(NSString *)requestReason completion:(BPLocationHandler)completionHandler
{
    if(sLocationDelegate)
    {
        sLocationDelegate.completionHandlers = [sLocationDelegate.completionHandlers arrayByAddingObject:completionHandler];
        return;
    }
    
    sLocationDelegate = [[BPLocationDelegate alloc] initWithCompletionHandler:completionHandler];
    
    // Don't display the alert if they have perm denied or restricted our ability to get location information.
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        NSError *error = [NSError errorWithDomain:kCLErrorDomain
                                             code:kCLErrorDenied
                                         userInfo:nil];
        [sLocationDelegate completeWithLocation:nil error:error];
        return;
    }
    
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        // Location services not enabled, get permission.
        [[UIAlertView alertWithTitle:nil
                            message:requestReason
                  cancelButtonTitle:@"Cancel"
                  otherButtonTitles:@[@"Okay"]
                  completionHandler:^(UIAlertView *alertView, NSUInteger buttonClicked) {
                      
                      if(buttonClicked == alertView.cancelButtonIndex)
                      {
                          NSError *error = [NSError errorWithDomain:kCLErrorDomain
                                                               code:kCLErrorDenied
                                                           userInfo:nil];
                          [sLocationDelegate completeWithLocation:nil error:error];
                          return;
                      }
                      [sLocationDelegate start];
                  }] show];
        return;
    }
    
    // We have permissions, proceed as usual.    
    [sLocationDelegate start];
}
@end
