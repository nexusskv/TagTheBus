//
//  ApiConnector.m
//  TagTheBus
//
//  Created by Rost on 25.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "ApiConnector.h"
#import "DataFetcher.h"


@implementation ApiConnector


#pragma mark - initWithCallback:
- (id)initWithCallback:(ApiConnectorCallback)block {
    if (self = [super init])
        self.callbackBlock = block;
    
    return self;
}
#pragma mark -


#pragma mark - downloadList
- (void)downloadList {
    NSURL *requestURL = [NSURL URLWithString:@"http://barcelonaapi.marcpous.com/bus/nearstation/latlon/41.3985182/2.1917991/1.json"];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSMutableURLRequest *requestToApi = [NSMutableURLRequest requestWithURL:requestURL];
    requestToApi.HTTPMethod = @"GET";
    
    NSURLSessionDataTask *dataTask =
    [urlSession dataTaskWithRequest:requestToApi
                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                      
                      if ((data) && (data.length > 0)) {
                          NSError *jsonError = nil;
                          NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                     options:NSJSONReadingMutableLeaves
                                                                                       error:&jsonError];
                          
                          if ([[jsonObject objectForKey:@"code"] intValue] == 200) {
                              NSArray *allStations = [jsonObject valueForKeyPath:@"data.nearstations"];
                              
                              if ([allStations count] > 0) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [[DataFetcher shared] saveObjects:allStations forEntity:@"Station"];
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          self.callbackBlock(@YES);
                                      });
                                  });
                              } else {
                                  self.callbackBlock(@"Received list is empty.");
                              }
                          } else {
                              NSLog(@"Parsing JSON error: %@", jsonError);
                              self.callbackBlock(jsonError);
                          }
                      }
                  }];
    
    [dataTask resume];
}
#pragma mark -

@end
