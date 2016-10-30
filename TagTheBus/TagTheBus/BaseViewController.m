//
//  BaseViewController.m
//  TagTheBus
//
//  Created by Rost on 28.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "BaseViewController.h"
#import "UIImage+Category.h"


@interface BaseViewController ()

@end


@implementation BaseViewController


#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *iconImage = [UIImage resizeImage:[UIImage imageNamed:@"back button"] toSize:CGSizeMake(20.0f, 20.0f)];
    UIColor *titleColor = [UIColor colorWithRed:68.0f/255.0f green:120.0f/255.0f blue:251.0f/255.0f alpha:1.0f];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0, 0.0, 70.0f, 40.0f);
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, -35.0f, 0.0f, 0.0f);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, -35.0f, 0.0f, 0.0f);
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:titleColor forState:UIControlStateNormal];
    [backButton setImage:iconImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}
#pragma mark -


#pragma mark - backButtonTapped
- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -


#pragma mark - showAlertMessage:
- (void)showAlertMessage:(NSString *)message {
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error message."
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {}];
        
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    #else
        [[[UIAlertView alloc] initWithTitle:@"Error message."
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    #endif
}
#pragma mark -


#pragma mark - getSortDescriptorsByKey:andAsc:
- (NSArray *)getSortDescriptorsByKey:(NSString *)key andAsc:(BOOL)ascending {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
    return @[sortDescriptor];
}
#pragma mark -


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
