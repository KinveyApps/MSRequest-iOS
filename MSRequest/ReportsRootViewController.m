//
//  ReportsRootViewController.m
//  MSRequest
//
//  Created by Pavel Vilbik on 15.4.14.
/**
 * Copyright (c) 2014, Kinvey, Inc. All rights reserved. *
 * This software is licensed to you under the Kinvey terms of service located at
 * http://www.kinvey.com/terms-of-use. By downloading, accessing and/or using this
 * software, you hereby accept such terms of service (and any agreement referenced
 * therein) and agree that you have read, understand and agree to be bound by such
 * terms of service and are of legal age to agree to such terms with Kinvey. *
 * This software contains valuable confidential and proprietary information of
 * KINVEY, INC and is subject to applicable licensing agreements.
 * Unauthorized reproduction, transmission or distribution of this file and its
 * contents is a violation of applicable laws. *
 */

#import "ReportsRootViewController.h"
#import "MapAnnotation.h"
#import "ReportDetailViewController.h"
#import "UIImage+Resize.h"

#import "DataHelper.h"
#import <KinveyKit/KinveyKit.h>
#import "RootCollectionViewCell.h"
#import "AppDelegate.h"

#define MILES_PER_METER     0.000621371192

@interface ReportsRootViewController () <CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, retain) CLLocationManager* locationManager;
@property (strong, nonatomic) NSArray *reportsData;
@property (strong, nonatomic) KCSQuery *query;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ReportsRootViewController


#pragma mark - Setters and Getters

- (KCSQuery *)query{
    if (!_query) {
        _query = [KCSQuery query];
    }
    return _query;
}


#pragma mark - Collection View
#pragma mark - Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.reportsData.count ? self.reportsData.count : 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.reportsData.count) {
        NSString *cellID = @"kRootCollectionViewCell";
        
        RootCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID
                                                                                 forIndexPath:indexPath];
        if (!cell) {
            cell = [[RootCollectionViewCell alloc] init];
        }
        Report *report = (Report *)self.reportsData[indexPath.row];
        if (report) {
            cell.typeLabel.text = report.type.name;
            cell.statusLabel.text = [NSString stringWithFormat:@"State: %@", report.type.reportState[[report.state integerValue]]];
            cell.descriptionLabel.text = report.descriptionOfReport;
            cell.locationsLabel.text = report.locationString;
            cell.kinveyImageView.kinveyID = report.thumbnailId;
            cell.distanceLabel.text = [NSString stringWithFormat:@"distance: %.3f km", [self reportDistanceFromCurrentLocation:report]/1000.0];
        }
        
        return cell;
        
    }else{
        
        NSString *cellID = @"kDefaultCollectionViewCell";
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID
                                                                                 forIndexPath:indexPath];
        if (!cell) {
            cell = [[UICollectionViewCell alloc] init];
        }
        
        return cell;
        
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self showDetailViewForReport:self.reportsData[indexPath.row]];
}


#pragma mark - Utils

- (void)showDetailViewForReport:(Report *)report
{
    if (self.navigationController.topViewController != self) {
        
        [self.navigationController popToViewController:self animated:NO];
    }
    [self performSegueWithIdentifier:@"kSegueIdentifierPushReportDetails" sender:report];
}

- (float)reportDistanceFromCurrentLocation:(Report *)report
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        CLLocation *userLocation = [[CLLocation alloc] initWithCoordinate:[self.locationManager location].coordinate
                                                                 altitude:1
                                                       horizontalAccuracy:1
                                                         verticalAccuracy:1
                                                                timestamp:nil];
        CLLocation *reportLocation = [[CLLocation alloc] initWithCoordinate:report.geoCoord.coordinate
                                                                 altitude:1
                                                       horizontalAccuracy:1
                                                         verticalAccuracy:1
                                                                timestamp:nil];
        return [reportLocation distanceFromLocation:userLocation];  // meters
    } else {
        return INFINITY;
    }
}

- (void)dataLoadUseCache:(BOOL)cache{

    //Load data from kinvey
    [[DataHelper instance] loadReportUseCache:cache
                                    withQuery:nil
                                    OnSuccess:^(NSArray *reports){
                                        
                                        self.reportsData = reports;
                                        [self.collectionView reloadData];
                                        if ([self.refreshControl isRefreshing]) {
                                            [self.refreshControl endRefreshing];
                                        }
                                        
                                    }onFailure:nil];
}


#pragma mark - Actions

- (IBAction)logout:(id)sender
{
    [[KCSUser activeUser] logout];
    [self.navigationController popViewControllerAnimated:YES];

}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"kSegueIdentifierPushReportDetails"]) {
        if ([sender isKindOfClass:[Report class]]) {
            ((ReportDetailViewController *)segue.destinationViewController).report = sender;
        }
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 1000.0;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    [self dataLoadUseCache:YES];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)refresh{
    [self dataLoadUseCache:NO];
}


- (IBAction)newReportButtonPressed:(id)sender {
    // animate button
    
    [self performSegueWithIdentifier:@"kSegueIdentifierNewReport" sender:sender];

}

- (IBAction)settingButtonPress:(UIBarButtonItem *)sender {
}

#pragma mark - Location Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //reload the data to update locations
    [self.collectionView reloadData];
}


@end
