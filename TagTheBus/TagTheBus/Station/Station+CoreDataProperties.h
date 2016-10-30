//
//  Station+CoreDataProperties.h
//  
//
//  Created by Rost on 30.10.16.
//
//  This file was automatically generated and should not be edited.
//

#import "Station.h"


NS_ASSUME_NONNULL_BEGIN

@interface Station (CoreDataProperties)

+ (NSFetchRequest<Station *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *buses;
@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSString *distance;
@property (nullable, nonatomic, copy) NSString *furniture;
@property (nullable, nonatomic, copy) NSString *lat;
@property (nullable, nonatomic, copy) NSString *lon;
@property (nullable, nonatomic, copy) NSString *object_id;
@property (nullable, nonatomic, copy) NSString *street_name;
@property (nullable, nonatomic, copy) NSString *utm_x;
@property (nullable, nonatomic, copy) NSString *utm_y;

@end

NS_ASSUME_NONNULL_END
