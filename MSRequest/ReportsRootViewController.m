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

- (void) setThumbnailForCell:(CustomReportTableViewCell *)cell withImage:(UIImage *)image;

@end

@implementation ReportsRootViewController

- (KCSQuery *)query{
    if (!_query) {
        _query = [KCSQuery query];
    }
    return _query;
}

#pragma mark - Collection View
#pragma mark - Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.reportsData.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
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
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self showDetailViewForReport:self.reportsData[indexPath.row]];
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

- (void)showDetailViewForReport:(Report *)report
{
    if (self.navigationController.topViewController != self) {
        //if the there is a subview showing, go back to the beginning, in order to preserve the stack behavior
        //if this is called via deplinking, 
        [self.navigationController popToViewController:self animated:NO];
    }
    [self performSegueWithIdentifier:@"kSegueIdentifierPushReportDetails" sender:report];
}

- (IBAction)logout:(id)sender
{
    [[KCSUser activeUser] logout];
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"kSegueIdentifierPushReportDetails"]) {
        if ([sender isKindOfClass:[Report class]]) {
            ((ReportDetailViewController *)segue.destinationViewController).report = sender;
        }
    }
    else if ([segue.identifier isEqualToString:@"kSegueIdentifierReportFilter"]) {
        ((ReportsFilterViewController *)segue.destinationViewController).delegate = self;
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

- (void)refresh{
    [self dataLoadUseCache:NO];
}


- (IBAction)newReportButtonPressed:(id)sender {
    // animate button
    
    [self performSegueWithIdentifier:@"kSegueIdentifierNewReport" sender:sender];

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - ReportsFilterViewControllerDelegate

- (void)reportFilterEditingFinishedWithOptions:(NSDictionary *)options {
//    currentFilterOption = [[options objectForKey:kFilterOptionKey] intValue];
//    currentTableSortOption = [[options objectForKey:kSortOptionKey] intValue];
//    [self dataLoad];
//    [self.reportsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)reportFilterEditingFinishedWithFilterOption:(NSInteger)filterRow sortOption:(NSInteger)sortRow {
//    currentFilterOption = filterRow;
//    currentTableSortOption = sortRow;
//    [self dataLoad];
//    [self.reportsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
}


- (void) setThumbnailForCell:(CustomReportTableViewCell *)cell withImage:(UIImage *)image
{
    // load the image on a background thread and update the screen on the main thread.
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        UIImage *imageBlock = image;
        imageBlock = [imageBlock thumbnailImage:100 transparentBorder:0 cornerRadius:7 interpolationQuality:kCGInterpolationDefault];
        dispatch_queue_t mainThreadQueue = dispatch_get_main_queue();
        dispatch_async(mainThreadQueue, ^{
            cell.reportImage.image = imageBlock;
        });
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Report *selectedReport = [self.reportsData objectAtIndex:indexPath.row];
    [self showDetailViewForReport:selectedReport];
}

#pragma mark - Location Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //reload the data to update locations
    [self.collectionView reloadData];
    
}


- (IBAction)calloutButtonPressed:(UIButton *)sender {
    MKAnnotationView *view = (MKAnnotationView *)sender.superview/*callout view*/.superview/*annotation view*/;
    [self showDetailViewForReport:((MapAnnotation *)view.annotation).reportModel];
}

- (void)viewDidUnload{

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
