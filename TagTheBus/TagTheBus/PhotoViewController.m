//
//  PhotoViewController.m
//  TagTheBus
//
//  Created by Rost on 28.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "PhotoViewController.h"
#import "DataFetcher.h"
#import "Station.h"
#import "StationPhoto.h"
#import "AppDelegate.h"


@interface PhotoViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@end


@implementation PhotoViewController


#pragma mark - View life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (self.photoData) {
        self.title = @"Title of the photo";
        
        [self.titleTextField becomeFirstResponder];
        self.photoImageView.image = [UIImage imageWithData:self.photoData];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                               target:self
                                                                                               action:@selector(saveItemTapped)];
    } else {
        NSString *predicate = [NSString stringWithFormat:@"station_id = '%lu'", (unsigned long)self.detailedObjectId];
        StationPhoto *existPhoto = [[[DataFetcher shared] fetchByEntity:@"StationPhoto" andPredicate:predicate] lastObject];
        
        self.title = existPhoto.photo_title;
        
        self.photoImageView.image   = [UIImage imageWithData:existPhoto.photo_data];
        self.titleTextField.hidden  = YES;
        
        self.navigationItem.rightBarButtonItem = nil;
    }
}
#pragma mark - 


#pragma mark - saveItemTapped
- (void)saveItemTapped {
    if ([self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [self showAlertMessage:@"Please enter a good title"];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        StationPhoto *createdPhoto  = [[DataFetcher shared] createEntityByClass:@"StationPhoto"];
        createdPhoto.station_id     = [NSString stringWithFormat:@"%lu", (unsigned long)self.detailedObjectId];
        createdPhoto.photo_title    = self.titleTextField.text;
        createdPhoto.photo_data     = UIImageJPEGRepresentation(self.photoImageView.image, 1.0f);
        createdPhoto.photo_date     = [self getCurrentDate];
        
        [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}
#pragma mark - 


#pragma mark - getCurrentDate
- (NSString *)getCurrentDate {
    NSString *resultString = nil;
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [outputFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    
    [outputFormatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    resultString = [outputFormatter stringFromDate:[NSDate date]];
    
    return resultString;
}
#pragma mark -


#pragma mark - UITextField delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    
    return YES;
}
#pragma mark -


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
