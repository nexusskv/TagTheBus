//
//  MapPin.m
//  TagTheBus
//
//  Created by Rost on 27.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "MapPin.h"


@implementation MapPin


#pragma mark - initWithLocation:
- (id)initWithLocation:(CLLocationCoordinate2D)location {
    self = [super init];
    
    if (self) {
        _coordinate = location;
    }
    
    return self;    
}
#pragma mark -

@end
