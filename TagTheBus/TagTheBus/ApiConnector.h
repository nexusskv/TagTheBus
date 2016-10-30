//
//  ApiConnector.h
//  TagTheBus
//
//  Created by Rost on 25.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ApiConnectorCallback)(id);


@interface ApiConnector : NSObject

@property (nonatomic, copy) ApiConnectorCallback callbackBlock;

- (id)initWithCallback:(ApiConnectorCallback)block;
- (void)downloadList;

@end
