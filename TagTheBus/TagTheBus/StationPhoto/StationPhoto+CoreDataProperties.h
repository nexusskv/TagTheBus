//
//  StationPhoto+CoreDataProperties.h
//  
//
//  Created by Rost on 30.10.16.
//
//

#import "StationPhoto.h"


NS_ASSUME_NONNULL_BEGIN

@interface StationPhoto (CoreDataProperties)

+ (NSFetchRequest<StationPhoto *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *photo_data;
@property (nullable, nonatomic, copy) NSString *photo_date;
@property (nullable, nonatomic, copy) NSString *photo_title;
@property (nullable, nonatomic, copy) NSString *station_id;

@end

NS_ASSUME_NONNULL_END
