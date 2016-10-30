//
//  MapPin.h
//  TagTheBus
//
//  Created by Rost on 27.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPin : NSObject <MKAnnotation>

@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (nonatomic) NSUInteger pinTag;

- (id)initWithLocation:(CLLocationCoordinate2D)location;

@end
