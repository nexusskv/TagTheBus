//
//  Station+CoreDataProperties.m
//  
//
//  Created by Rost on 30.10.16.
//
//  This file was automatically generated and should not be edited.
//

#import "Station+CoreDataProperties.h"

@implementation Station (CoreDataProperties)

+ (NSFetchRequest<Station *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Station"];
}

@dynamic buses;
@dynamic city;
@dynamic distance;
@dynamic furniture;
@dynamic lat;
@dynamic lon;
@dynamic object_id;
@dynamic street_name;
@dynamic utm_x;
@dynamic utm_y;

@end
