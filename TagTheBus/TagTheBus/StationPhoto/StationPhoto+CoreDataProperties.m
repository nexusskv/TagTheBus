//
//  StationPhoto+CoreDataProperties.m
//  
//
//  Created by Rost on 30.10.16.
//
//

#import "StationPhoto+CoreDataProperties.h"

@implementation StationPhoto (CoreDataProperties)

+ (NSFetchRequest<StationPhoto *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"StationPhoto"];
}

@dynamic photo_data;
@dynamic photo_date;
@dynamic photo_title;
@dynamic station_id;

@end
