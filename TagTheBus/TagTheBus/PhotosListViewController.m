//
//  PhotosListViewController.m
//  TagTheBus
//
//  Created by Rost on 25.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "PhotosListViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PhotoListTableCell.h"
#import "DataFetcher.h"
#import "StationPhoto.h"
#import "Station.h"
#import "PhotoViewController.h"
#import "UIImage+Category.h"


@interface PhotosListViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) NSData *createdPhotoData;
@end


@implementation PhotosListViewController


#pragma mark - View life cycle
- (void)loadView {
    [super loadView];
    
    UIButton *addPhotoButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addPhotoButton.frame = CGRectMake(0.0, 12.0, 20.0f, 20.0f);
    [addPhotoButton addTarget:self action:@selector(addPhoto) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                               target:nil
                                                                               action:nil];
    spaceItem.width = -10.0f;
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:addPhotoButton];
    self.navigationItem.rightBarButtonItems = @[spaceItem, barItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self createDataSource];
    
    self.createdPhotoData = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self createDataSource];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if ([self.listTable respondsToSelector:@selector(setSeparatorInset:)])
        [self.listTable setSeparatorInset:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
}
#pragma mark -


#pragma mark - createDataSource
- (void)createDataSource {
    __block NSString *predicate = [NSString stringWithFormat:@"object_id = '%lu'", (unsigned long)self.detailedObjectId];
    
    [[DataFetcher shared] fetchByEntity:@"Station"
                          withPredicate:predicate
                            andCallback:^(id resultObject) {
                                
        if ([resultObject isKindOfClass:[NSString class]]) {
            [self showAlertMessage:resultObject];
        } else if ([resultObject isKindOfClass:[NSArray class]]) {
            Station *selectedStation = [resultObject lastObject];
            
            self.title = selectedStation.street_name;
            
            predicate = [NSString stringWithFormat:@"station_id = '%@'", selectedStation.object_id];
            
            [[DataFetcher shared] fetchByEntity:@"StationPhoto"
                                  withPredicate:predicate
                                    andCallback:^(id resultObject) {
                                        
                if ([resultObject isKindOfClass:[NSString class]]) {
                    [self showAlertMessage:resultObject];
                } else if ([resultObject isKindOfClass:[NSArray class]]) {
                    NSArray *fetchedArray = (NSArray *)resultObject;
                    
                    if ([fetchedArray count] > 0) {
                        self.listArray = [fetchedArray sortedArrayUsingDescriptors:[self getSortDescriptorsByKey:@"photo_date"
                                                                                                          andAsc:NO]];
                        [self.listTable reloadData];
                    }
                }
            }];
        }
    }];
}
#pragma mark -


#pragma mark - Action selectors
- (void)addPhoto {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate                 = self;
        imagePicker.mediaTypes               = @[(NSString *)kUTTypeImage];
        
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            imagePicker.sourceType   = UIImagePickerControllerSourceTypeCamera;
        } else {
            imagePicker.sourceType   = UIImagePickerControllerSourceTypePhotoLibrary;   // source for simulator only
        }
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    });
}
#pragma mark -


#pragma mark - TableView dataSource & delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"PhotoListCell";
    
    PhotoListTableCell *cell = (PhotoListTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                                     forIndexPath:indexPath];
    
    StationPhoto *photoObject = self.listArray[indexPath.row];

    cell.photoImageView.image = [UIImage imageWithData:photoObject.photo_data];
    
    cell.photoTitleLabel.text = photoObject.photo_title;
    
    cell.photoDateLabel.text  = photoObject.photo_date;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"ShowPhoto" sender:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[DataFetcher shared] deleteDataObject:self.listArray[indexPath.row]];
        
        NSMutableArray *tempValues = [NSMutableArray arrayWithArray:self.listArray];
        [tempValues removeObjectAtIndex:indexPath.row];
        self.listArray = tempValues;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        [self createDataSource];
    }
}
#pragma mark -


#pragma mark - ImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    UIImage *newImage = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (!newImage)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *compressedImage = newImage;
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            if (compressedImage.imageOrientation == UIImageOrientationUp) {
                NSLog(@"portrait");
                compressedImage = [UIImage rotateImage:compressedImage withOrientation:compressedImage.imageOrientation];
            } else if (compressedImage.imageOrientation == UIImageOrientationLeft ||
                       compressedImage.imageOrientation == UIImageOrientationRight) {
                NSLog(@"landscape");
            }
        }
        
        if (compressedImage) {
            NSData *jpgData = UIImageJPEGRepresentation(compressedImage, 1.0f);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (jpgData) {
                    self.createdPhotoData = jpgData;

                    [self performSegueWithIdentifier:@"ShowPhoto" sender:self];
                }
            });
        }
    });    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -


#pragma mark - prepareForSegue:sender:
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *receivedSegueId = segue.identifier;
    
    if ([receivedSegueId isEqualToString:@"ShowPhoto"]) {
        PhotoViewController *photoVC = (PhotoViewController *)segue.destinationViewController;
        photoVC.detailedObjectId = self.detailedObjectId;
        
        if (self.createdPhotoData) {
            photoVC.photoData        = self.createdPhotoData;
        }
    }
}
#pragma mark -


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
