//
//  DataFetcher.m
//  TagTheBus
//
//  Created by Rost on 26.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "AppDelegate.h"
#import "DataFetcher.h"
#import "Station.h"
#import "StationPhoto.h"


@implementation DataFetcher


#pragma mark - Shared instance
+ (instancetype)shared {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}
#pragma mark -


#pragma mark - managedObjectContext
- (NSManagedObjectContext *)managedObjectContext {
    return ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
}
#pragma mark -


#pragma mark - fetchByEntity:withPredicate:andCallback:
- (void)fetchByEntity:(NSString *)title withPredicate:(NSString *)predicate andCallback:(DataFetcherCallback)block {
    NSError *fetchError           = nil;
    __block id fetchedValues      = nil;
    
    NSFetchRequest *newRequest = [self requestForEntity:title andPredicate:predicate];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        NSAsynchronousFetchRequest *asyncFR =
        [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:newRequest
                                                 completionBlock:^(NSAsynchronousFetchResult *result) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                 if ([result.finalResult count] > 0) {
                     fetchedValues = result.finalResult;
                     
                     block(fetchedValues);
                 } else if (fetchError) {
                     block(fetchError);
                 } else {
                     block(nil);
                 }
             });
         }];
        
        [self.managedObjectContext executeRequest:asyncFR error:&fetchError];
    } else {
        fetchedValues = [self fetchByEntity:title andPredicate:predicate];
        block(fetchedValues);
    }
}
#pragma mark -


#pragma mark - fetchByEntity:andPredicate:
- (id)fetchByEntity:(NSString *)title andPredicate:(NSString *)predicate {
    NSArray *valuesArray          = nil;
    NSError *fetchError           = nil;
    
    NSFetchRequest *newRequest = [self requestForEntity:title andPredicate:predicate];
    
    valuesArray = [self.managedObjectContext executeFetchRequest:newRequest error:&fetchError];
    
    if (fetchError) {
        NSLog(@"Fetch values as dictionary error -> %@ ", fetchError.description);
        return fetchError.description;
    } else if ([valuesArray count] > 0) {
        return valuesArray;
    }
    
    return nil;
}
#pragma mark -


#pragma mark - requestForEntity:andPredicate:
- (NSFetchRequest *)requestForEntity:(NSString *)entity andPredicate:(NSString *)predicate {
    NSEntityDescription *fetchEntity = [NSEntityDescription entityForName:entity
                                                   inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *newRequest          = [[NSFetchRequest alloc] init];
    newRequest.entity                   = fetchEntity;
    newRequest.returnsDistinctResults   = YES;
    newRequest.includesPropertyValues   = YES;
    
    if (predicate) {
        [newRequest setPredicate:[NSPredicate predicateWithFormat:predicate]];
    }
    
    return newRequest;
}
#pragma mark -


#pragma mark - saveObjects:forEntity:
- (void)saveObjects:(NSArray *)objects forEntity:(NSString *)entity {
    for (NSDictionary *objectValues in objects) {
        [self saveValues:objectValues forEntity:entity byKeys:[objectValues allKeys]];
    }
}
#pragma mark -


#pragma mark - saveValues:forEntity:byKeys:
- (void)saveValues:(id)values forEntity:(NSString *)entity byKeys:(NSArray *)keys {
    id newObject = nil;
    
    NSString *fetchPredicate = [NSString stringWithFormat:@"object_id == '%@'", values[@"id"]];
    NSArray *existsCheckArray = [self fetchByEntity:entity andPredicate:fetchPredicate];
    
    if ([existsCheckArray count] > 0) {
        newObject = [existsCheckArray lastObject];
    } else {
        newObject = [self createEntityByClass:entity];
    }
    
    if (newObject) {
        for (__strong NSString *key in keys) {
            NSString *saveKey = key;
            
            if ([key isEqualToString:@"id"]) {
                saveKey = @"object_id";
            }
            
            [newObject setValue:values[key] forKey:saveKey];
        }
        
        [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
    }
}
#pragma mark -


#pragma mark - createEntityByClass:
- (id)createEntityByClass:(NSString *)title {
        NSEntityDescription *saveEntity = [NSEntityDescription entityForName:title
                                                      inManagedObjectContext:self.managedObjectContext];
        
        id newObject = [[NSClassFromString(title) alloc] initWithEntity:saveEntity
                                         insertIntoManagedObjectContext:self.managedObjectContext];

    return newObject;
}
#pragma mark -


#pragma mark - deleteDataObject:
- (void)deleteDataObject:(id)object {
    [self.managedObjectContext deleteObject:object];
    
    [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
}
#pragma mark -

@end
