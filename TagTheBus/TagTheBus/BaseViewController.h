//
//  BaseViewController.h
//  TagTheBus
//
//  Created by Rost on 28.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BaseViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *listTable;
@property (strong, nonatomic) NSArray *listArray;
@property (nonatomic) NSUInteger detailedObjectId;

- (void)showAlertMessage:(NSString *)message;

- (NSArray *)getSortDescriptorsByKey:(NSString *)key andAsc:(BOOL)ascending;

@end
