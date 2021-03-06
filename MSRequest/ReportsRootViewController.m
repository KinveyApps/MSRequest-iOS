//
//  ReportsRootViewController.m
//  MSRequest
//
//  Created by Pavel Vilbik on 15.4.14.
/**
 * Copyright (c) 2014 Kinvey Inc. *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at *
 * http://www.apache.org/licenses/LICENSE-2.0 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License. *
 */

#import "ReportsRootViewController.h"
#import "MapAnnotation.h"
#import "ReportDetailViewController.h"
#import "UIImage+Resize.h"

#import "DataHelper.h"
#import <KinveyKit/KinveyKit.h>
#import "RootCollectionViewCell.h"
#import "AppDelegate.h"
#import "AHKActionSheet.h"
#import "DejalActivityView.h"
#import "EditHomeSreenTableViewController.h"
#import "NewReportViewController.h"
#import "AuthenticationHelper.h"

#define MILES_PER_METER     0.000621371192

@interface ReportsRootViewController () <CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, EditHomeSreenTableViewControllerDelegate, NewReportViewControllerDelegate>

@property (nonatomic, retain) CLLocationManager* locationManager;
@property (strong, nonatomic) NSArray *reportsData;
@property (strong, nonatomic) KCSQuery *query;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *reportCollectionViewFlowLayout;
@property (nonatomic, weak) UIPopoverController *popoverCotroller;

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
    return 1;   //report avaliable for reading
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
            cell.typeLabel.text = [report.type.name capitalizedString];
            cell.statusLabel.text = report.type.reportState[[report.state integerValue]];
            cell.descriptionLabel.text = report.descriptionOfReport;
            cell.locationsLabel.text = report.locationString;
            cell.kinveyImageView.kinveyID = report.thumbnailId;
            cell.distanceLabel.text = [NSString stringWithFormat:@"%.1f m", [self reportDistanceFromCurrentLocation:report]];
            [self setupCell:cell];
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

- (void)setupCell:(RootCollectionViewCell *)cell{
//    [self setBlurForView:cell.headerBlurView];
    cell.statusLabel.textColor = [UIColor colorWithRed:0 green:0.549 blue:0.5176 alpha:1.0];
}

- (void)setBlurForView:(UIView *)view{
    [view setClipsToBounds:YES];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:[view bounds]];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    toolbar.barStyle = UIBarStyleDefault;
    toolbar.translucent = YES;
    toolbar.barTintColor = nil;

    [view insertSubview:toolbar atIndex:0];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|"
                                                                 options:0
                                                                 metrics:0
                                                                   views:NSDictionaryOfVariableBindings(toolbar)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar]|"
                                                                 options:0
                                                                 metrics:0
                                                                   views:NSDictionaryOfVariableBindings(toolbar)]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self showDetailViewForReport:self.reportsData[indexPath.row]];
}


#pragma mark - Utils

- (void)showDetailViewForReport:(Report *)report{
    
//    if (self.navigationController.topViewController != self) {
//        
//        [self.navigationController popToViewController:self animated:NO];
//    }
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
                                        
                                    }onFailure:^(NSError *error){
                                        if ([self.refreshControl isRefreshing]) {
                                            [self.refreshControl endRefreshing];
                                        }
                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                            message:error.localizedDescription
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:@"Cancel"
                                                                                  otherButtonTitles:nil];
                                        [alertView show];
                                    }];
}

- (void)refresh{
    [self dataLoadUseCache:NO];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"kSegueIdentifierPushReportDetails"]) {
        if ([sender isKindOfClass:[Report class]]) {
            if ([segue.destinationViewController isKindOfClass:[ReportDetailViewController class]]) {
                ((ReportDetailViewController *)segue.destinationViewController).report = sender;
            }
            if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
                ReportDetailViewController *vc = (ReportDetailViewController *)[((UINavigationController *)segue.destinationViewController).viewControllers firstObject];
                vc.report = sender;
            }
        }
    }else if ([segue.identifier isEqualToString:@"kSegueIdentifierReportFilter"]){
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nvc = (UINavigationController *)segue.destinationViewController;
            EditHomeSreenTableViewController *vc = (EditHomeSreenTableViewController *)[nvc.viewControllers firstObject];
            vc.delegate = self;
        }
    }else if ([segue.identifier isEqualToString:@"kSegueIdentifierNewReport"]){
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            self.popoverCotroller = [(UIStoryboardPopoverSegue *)segue popoverController];
        }
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nvc = (UINavigationController *)segue.destinationViewController;
            NewReportViewController *vc = (NewReportViewController *)[nvc.viewControllers firstObject];
            vc.delegate = self;
        }
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 1000.0;   //for get only one update location if user not move
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    if (![DataHelper instance].currentUserRole.availableTypesForCreating.count) {
        
        //remove tab bar button of new report
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    [self dataLoadUseCache:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self updateCollectionViewCellSize];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self updateCollectionViewCellSize];
}

- (void)updateCollectionViewCellSize{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        NSInteger cellCount = 2;
        if ((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))) {
            cellCount = 3;
        }
        
        CGFloat width = ((NSInteger)(self.collectionView.bounds.size.width -
                                     self.reportCollectionViewFlowLayout.sectionInset.right -
                                     self.reportCollectionViewFlowLayout.sectionInset.left -
                                     self.reportCollectionViewFlowLayout.minimumInteritemSpacing * (cellCount - 1))) / cellCount;
        self.reportCollectionViewFlowLayout.itemSize = CGSizeMake(width, width * 1.25);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - Actions

- (IBAction)newReportButtonPressed:(id)sender {
    
    if ([DataHelper instance].currentUserRole.availableTypesForCreating.count) {
        [self performSegueWithIdentifier:@"kSegueIdentifierNewReport" sender:sender];
    }else{
        [[[UIAlertView alloc] initWithTitle:@"Unavailble Action"
                                    message:@"You haven't right to create any report."
                                   delegate:nil
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:nil] show];
    }

}

- (IBAction)settingButtonPress:(UIBarButtonItem *)sender {
    
    //create action sheet with setting actions
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:@"Settings"];
    
    [actionSheet addButtonWithTitle:@"Edit Home Screen"
                              image:[UIImage imageNamed:@"EditHomeButtonImage"]
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *actionSheet){
                                [self performSegueWithIdentifier:@"kSegueIdentifierReportFilter"
                                                          sender:self];
                            }];
    [actionSheet addButtonWithTitle:@"Notification Settings"
                              image:[UIImage imageNamed:@"NotificationButtonImage"]
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *actionSheet){
                                [self performSegueWithIdentifier:@"kSegueIdentifierNotificationSettings"
                                                          sender:self];
                            }];
    [actionSheet addButtonWithTitle:@"Sign Out"
                              image:[UIImage imageNamed:@"SignOutButtonImage"]
                               type:AHKActionSheetButtonTypeDestructive
                            handler:^(AHKActionSheet *actionSheet){
                                
                                [DejalBezelActivityView activityViewForView:self.view.superview.superview.superview];
                                
                                //Kinvey: remove device token from user info
                                [[KCSPush sharedPush] unRegisterDeviceToken:^(BOOL success, NSError* error){
                                    
                                    //Return to main thread for update UI
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [DejalBezelActivityView removeView];
                                        if (!error) {
                                            [[AuthenticationHelper instance] logout];
                                            [DataHelper instance].filterOptions = nil;
                                            [self.navigationController popViewControllerAnimated:YES];
                                        }else{
                                            [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:error.localizedDescription
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Cancel"
                                                              otherButtonTitles:nil] show];
                                        }
                                    });
                                }];
                            }];
    
    [actionSheet showInView:self.navigationController];
    
}

#pragma mark - Location Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    [DataHelper instance].currentLocation = [locations lastObject];
    [self dataLoadUseCache:YES];
    //reload the data to update locations
    [self.collectionView reloadData];
}


#pragma mark - Edit home screen view controller delegate

- (void)savePress:(EditHomeSreenTableViewController *)sender{
    [self refresh];
}

#pragma mark - New report view controller delegate

- (void)submitFinish:(NewReportViewController *)sender{
    [self refresh];
    [self.popoverCotroller dismissPopoverAnimated:YES];
}

- (void)needChangeToSize:(CGSize)size sender:(NewReportViewController *)sender{
    [self.popoverCotroller setPopoverContentSize:size animated:NO];
}

@end
