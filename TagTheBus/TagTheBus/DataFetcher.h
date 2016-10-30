//
//  DataFetcher.h
//  TagTheBus
//
//  Created by Rost on 26.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DataFetcher : NSObject

+ (instancetype)shared;

- (NSArray *)fetchByEntity:(NSString *)title andPredicate:(NSString *)predicate;
- (void)saveObjects:(NSArray *)objects forEntity:(NSString *)entity;
- (void)saveValues:(id)values forEntity:(NSString *)entity byKeys:(NSArray *)keys;
- (id)createEntityByClass:(NSString *)title;
- (void)deleteDataObject:(id)object;

@end
