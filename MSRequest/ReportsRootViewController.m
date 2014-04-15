//
//  ReportsRootViewController.m
//  CityWatch
//
//  Copyright 2012-2013 Kinvey, Inc
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

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
        cell.statusLabel.text = report.type.reportState[[report.state integerValue]];
        cell.descriptionLabel.text = report.descriptionOfReport;
        cell.locationsLabel.text = report.locationString;
        cell.kinveyImageView.kinveyID = report.imageId;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self showDetailViewForReport:self.reportsData[indexPath.row]];
}


- (float)reportDistanceFromCurrentLocation:(Report *)report
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        CLLocationCoordinate2D userCoordinate = [self.locationManager location].coordinate;
        CLLocation *userLocation = [[CLLocation alloc] initWithCoordinate:userCoordinate
                                                                 altitude:1
                                                       horizontalAccuracy:1
                                                         verticalAccuracy:1
                                                                timestamp:nil];
        
        
        return [report.geoCoord distanceFromLocation:userLocation];  // meters
    } else {
        return INFINITY;
    }
}

- (void)dataLoad{

    [[DataHelper instance] loadReportUseCache:YES
                                    withQuery:nil
                                    OnSuccess:^(NSArray *reports){
                                        self.reportsData = reports;
                                        [self.collectionView reloadData];
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

    [self dataLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    [self dataLoad];
    
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    [self dataLoad];
}


- (IBAction)newReportButtonPressed:(id)sender {
    // animate button
    
    [self performSegueWithIdentifier:@"kSegueIdentifierNewReport" sender:sender];

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
