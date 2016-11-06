//
//  StationsViewController.m
//  TagTheBus
//
//  Created by Rost on 25.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "StationsViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ApiConnector.h"
#import "StationTableCell.h"
#import "Station.h"
#import "DataFetcher.h"
#import "PhotosListViewController.h"
#import "MapPin.h"
#import "SVProgressHUD.h"


@interface StationsViewController () <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *stationsMap;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewModeControl;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUInteger selectedObjectId;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) CLLocationCoordinate2D centerRegion;
@end


@implementation StationsViewController


#pragma mark - View life cycle
- (void)loadView {
    [super loadView];
    
    self.title = @"Tag The Bus !";
    
    [self createDataSource];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.listTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([self.listTable respondsToSelector:@selector(setSeparatorInset:)])
        [self.listTable setSeparatorInset:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Update bus stations."];
    [self.refreshControl addTarget:self action:@selector(refreshControlSelector:) forControlEvents:UIControlEventValueChanged];
    [self.listTable addSubview:self.refreshControl];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate           = self;
    self.locationManager.desiredAccuracy    = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter     = kCLDistanceFilterNone;
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [self.locationManager requestAlwaysAuthorization];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [self.locationManager requestWhenInUseAuthorization];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.stationsMap.isHidden)
        self.navigationItem.leftBarButtonItem = nil;
    
    if ([self.listArray count] > 0) {
        [self addStationsPinsToMap];
        
        if (!self.stationsMap.isHidden)
            [self moveToPins];
    }
}
#pragma mark -


#pragma mark - Actions
- (IBAction)changeViewMode:(id)sender {
    __weak __typeof(self)weakSelf = self;
    
    if (self.viewModeControl.selectedSegmentIndex == 0) {
        [UIView transitionFromView:self.listTable toView:self.stationsMap
                          duration:0.7f
                           options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionShowHideTransitionViews
                        completion:^(BOOL finished) {
                            __strong __typeof(weakSelf) strongSelf = weakSelf;
                            
                            strongSelf.stationsMap.hidden   = NO;
                            strongSelf.listTable.hidden     = YES;

                            
                            UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
                            locationButton.frame = CGRectMake(0.0, 15.0, 18.0f, 16.0f);
                            [locationButton setBackgroundImage:[UIImage imageNamed:@"current location icon"]
                                                      forState:UIControlStateNormal];
                            [locationButton addTarget:self action:@selector(updateLocation) forControlEvents:UIControlEventTouchUpInside];
                            
                            UIBarButtonItem *locationItem = [[UIBarButtonItem alloc] initWithCustomView:locationButton];
                            strongSelf.navigationItem.rightBarButtonItem = locationItem;
                            
                            
                            UIButton *pinsButton = [UIButton buttonWithType:UIButtonTypeCustom];
                            pinsButton.frame = CGRectMake(0.0, 0.0, 20.0f, 20.0f);
                            [pinsButton setBackgroundImage:[UIImage imageNamed:@"pins icon"]
                                                      forState:UIControlStateNormal];
                            [pinsButton addTarget:self action:@selector(moveToPins) forControlEvents:UIControlEventTouchUpInside];
                            
                            UIBarButtonItem *pinItem = [[UIBarButtonItem alloc] initWithCustomView:pinsButton];
                            strongSelf.navigationItem.leftBarButtonItem = pinItem;
                            
                            [self moveToPins];
                        }];
    } else {
        [UIView transitionFromView:self.stationsMap toView:self.listTable
                          duration:0.7f
                           options:UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionShowHideTransitionViews
                        completion:^(BOOL finished) {
                            __strong __typeof(weakSelf) strongSelf = weakSelf;
                            
                            strongSelf.listTable.hidden = NO;
                            strongSelf.stationsMap.hidden   = YES;
                            
                            strongSelf.navigationItem.rightBarButtonItem = nil;
                            strongSelf.navigationItem.leftBarButtonItem  = nil;
                        }];
    }
}
#pragma mark - 


#pragma mark - ApiСonnnector method
- (void)sendRequestToApi {
    [SVProgressHUD show];

    ApiConnector *apiConnector = [[ApiConnector alloc] initWithCallback:^(id resultObject) {
        if ([resultObject isKindOfClass:[NSNumber class]]) {
            
            if ([(NSNumber *)resultObject boolValue] == YES) {
                [self createDataSource];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    
                    [self hideRefreshIndicator];
                });
            }
        }
    }];
    
    [apiConnector downloadList];
}
#pragma mark -


#pragma mark - createDataSource
- (void)createDataSource {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DataFetcher shared] fetchByEntity:@"Station"
                              withPredicate:nil
                                andCallback:^(id resultObject) {
                                    
            if ([resultObject isKindOfClass:[NSString class]]) {
                [self showAlertMessage:resultObject];
            } else if ([resultObject isKindOfClass:[NSArray class]]) {
                NSArray *fetchedArray = (NSArray *)resultObject;
                
                if ([fetchedArray count] > 0) {
                    self.listArray = [fetchedArray sortedArrayUsingDescriptors:[self getSortDescriptorsByKey:@"street_name"
                                                                                                      andAsc:YES]];
                    
                    [self.listTable reloadData];
                    
                    [self addStationsPinsToMap];
                }
            } else {
                [self sendRequestToApi];
            }
        }];
    });
}
#pragma mark -


#pragma mark - updateLocation
- (void)updateLocation {
    [self.locationManager startUpdatingLocation];
}
#pragma mark -


#pragma mark - moveToPins
- (void)moveToPins {
    if (self.centerRegion.latitude == 0.0f) {
        NSArray *tempArray = self.listArray;
        NSArray *latArray = [tempArray sortedArrayUsingDescriptors:[self getSortDescriptorsByKey:@"lat" andAsc:YES]];
        NSArray *lonArray = [tempArray sortedArrayUsingDescriptors:[self getSortDescriptorsByKey:@"lon" andAsc:YES]];
        
        Station *latMinObject = latArray[0];
        Station *latMaxObject = latArray[[latArray count] - 1];
        Station *lonMinObject = lonArray[0];
        Station *lonMaxObject = lonArray[[lonArray count] - 1];
        
        double latMin = [latMinObject.lat doubleValue];
        double latMax = [latMaxObject.lat doubleValue];
        double latDifference = (latMax - latMin) / 2.0;
        double latCenter = latMax - latDifference;
        
        double lonMin = [lonMinObject.lon doubleValue];
        double lonMax = [lonMaxObject.lon doubleValue];
        double lonDifference = (lonMax - lonMin) / 2.0;
        double lonCenter = lonMax - lonDifference;
        
        self.centerRegion = CLLocationCoordinate2DMake(latCenter, lonCenter);
    }

    [self setRegionFromCoordinate:self.centerRegion];
}
#pragma mark -


#pragma mark - addStationsPinsToMap
- (void)addStationsPinsToMap {
    int count = 0;
    
    for (Station *stationObject in self.listArray) {
        if (([stationObject.lat doubleValue] > 0) && ([stationObject.lon doubleValue] > 0)) {
            CLLocationCoordinate2D pinLocation = CLLocationCoordinate2DMake([stationObject.lat doubleValue], [stationObject.lon doubleValue]);
            MapPin *newPin =  [[MapPin alloc] initWithLocation:pinLocation];
            
            newPin.pinTag  = [stationObject.object_id intValue];
            
            if ((stationObject.street_name != nil) && (stationObject.street_name.length > 0))
                newPin.title = stationObject.street_name;
            
            [self.stationsMap addAnnotation:newPin];
            
            if (count == [self.listArray count] / 2) {
                [self setRegionFromCoordinate:pinLocation];
            }
            
            count += 1;
        }
    }
}
#pragma mark -


#pragma mark - setRegionFromCoordinate:
- (void)setRegionFromCoordinate:(CLLocationCoordinate2D)location {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.007f;
    span.longitudeDelta = 0.007f;
    region.span = span;
    region.center = location;
    [self.stationsMap setRegion:region animated:YES];
}
#pragma mark -


#pragma mark - TableView dataSource & delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"StationCell";
    
    StationTableCell *cell = (StationTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Station *stationObject = self.listArray[indexPath.row];
    
    cell.titleLabel.text = stationObject.street_name;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Station *selectedStation = self.listArray[indexPath.row];
    self.selectedObjectId = [selectedStation.object_id intValue];
    
    [self performSegueWithIdentifier:@"ShowPhotosList" sender:self];
}
#pragma mark -


#pragma mark - MKMapView delegate mothods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    annotationView.canShowCallout = YES;
    
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    detailButton.frame     = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    [detailButton setBackgroundImage:[UIImage imageNamed:@"pin details"] forState:UIControlStateNormal];
    
    MapPin *annotationPin = (MapPin *)annotation;
    detailButton.tag      = annotationPin.pinTag;
    
    annotationView.rightCalloutAccessoryView = detailButton;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    UIButton *detailsButton = (UIButton *)control;    
    self.selectedObjectId   = detailsButton.tag;
    
    [self performSegueWithIdentifier:@"ShowPhotosList" sender:self];
}
#pragma mark -


#pragma mark - CoreLocation delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (![newLocation isEqual:oldLocation]) {
        [self.locationManager stopUpdatingLocation];
        
        [self setRegionFromCoordinate:newLocation.coordinate];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"locationManager:%@ didFailWithError:%@", manager, error);
    [self showAlertMessage:@"Please enable current location \n in settings on your simulator or device."];
}
#pragma mark -


#pragma mark - refreshControl methods
- (void)refreshControlSelector:(id)sender {
    [self.locationManager startUpdatingLocation];
    
    [self sendRequestToApi];
}

- (void)hideRefreshIndicator {
    [self.refreshControl endRefreshing];
}
#pragma mark -


#pragma mark - prepareForSegue:sender:
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *receivedSegueId = segue.identifier;
    
    if ([receivedSegueId isEqualToString:@"ShowPhotosList"]) {
        PhotosListViewController *photosListVC = (PhotosListViewController *)segue.destinationViewController;
        photosListVC.detailedObjectId = self.selectedObjectId;
    }
}
#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
