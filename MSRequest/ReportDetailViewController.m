//
//  ReportDetailViewController.m
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

#import "ReportDetailViewController.h"
#import "ImageScrollViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DataHelper.h"
#import "PhotoTableViewCell.h"
#import "LabelTableViewCell.h"
#import "DejalActivityView.h"
#import "AHKActionSheet.h"

typedef enum {
    PhotoReportTableViewRowIndex = 0,
    TypeReportTableViewRowIndex,
    StateReportTableViewRowIndex,
    LocationReportTableViewRowIndex,
    DescriptionReportTableViewRowIndex,
    FirstAdditionalAttributeReportTableViewRowIndex
} ReportTableViewRowIndex;

typedef enum {
    MainReportTableViewSectionIndex = 0,
    ChangeStatusReportTableViewSectionIndex
} ReportTableViewSectionIndex;

#define DEFAULT_ROW_HEIGHT 44;
#define PHOTO_ROW_HEIGHT 320;

NSString *const kSegueIdentifierPushImageViewer = @"kSegueIdentifierPushImageViewer";

@interface ReportDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL statusWasChanged;
@property (nonatomic) NSInteger currentServerState;
@property (nonatomic, strong) UIBarButtonItem *defaultBackBarItem;
@property (nonatomic) BOOL canChangeState;

@end

@implementation ReportDetailViewController


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    self.canChangeState = NO;
    for (TypeOfReport *type in [DataHelper instance].currentUserRole.availableTypesForChangingStatus) {
        if ([type.entityId isEqualToString:self.report.type.entityId]) {
            self.canChangeState = YES;
            break;
        }
    }
    self.navigationItem.title = [self.report.type.name capitalizedString];
    self.currentServerState = [self.report.state integerValue];
    self.defaultBackBarItem = self.navigationItem.leftBarButtonItem;
}

// in viewWillAppear/Disappear, toggle nav bar hidden for smooth transition with parent vc
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifierPushImageViewer]) {
        ImageScrollViewController *dest = segue.destinationViewController;
        dest.kinveyImageId = self.report.imageId;
        dest.navigationItem.title = self.navigationItem.title;
    }
}


#pragma mark - Table View
#pragma mark - Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == MainReportTableViewSectionIndex) {
        if (self.report.type) {
            
            return FirstAdditionalAttributeReportTableViewRowIndex + self.report.type.additionalAttributes.count;
            
        }else{
            
            return 2;
        }
    }else if (section == ChangeStatusReportTableViewSectionIndex){
        return 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.statusWasChanged) {
        return 2;
    }
    return 1;
}

#pragma mark - Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == MainReportTableViewSectionIndex) {
        
        switch (indexPath.row) {
                
            case PhotoReportTableViewRowIndex:{
                PhotoTableViewCell *cell = [self photoCellForTableView:tableView];
                
                return cell;
            }break;
                
            case TypeReportTableViewRowIndex:{
                UITableViewCell *cell = [self labelCellForTableView:tableView
                                                          withLabel:@"Type"
                                                     andDetailLabel:self.report.type.name.length ? self.report.type.name : @"No type"];
                
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }break;
                
            case StateReportTableViewRowIndex:{
                UITableViewCell *cell = [self labelCellForTableView:tableView
                                                          withLabel:@"State"
                                                     andDetailLabel:self.report.type.reportState[[self.report.state integerValue]]];
                if (!self.canChangeState) {
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                return cell;
            }break;
                
            case LocationReportTableViewRowIndex:{
                UITableViewCell *cell = [self labelCellForTableView:tableView
                                                          withLabel:@"Locations"
                                                     andDetailLabel:self.report.locationString.length ? self.report.locationString : @"No locations"];
                
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }break;
                
            case DescriptionReportTableViewRowIndex:{
                UITableViewCell *cell = [self labelCellForTableView:tableView
                                                          withLabel:@"Description"
                                                     andDetailLabel:self.report.descriptionOfReport.length ? self.report.descriptionOfReport : @"No description"];
                
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }break;
                
            default:{
                NSInteger additionalAttributeIndex = indexPath.row - FirstAdditionalAttributeReportTableViewRowIndex;
                UITableViewCell *cell = [self labelCellForTableView:tableView
                                                          withLabel:((NSString *)self.report.type.additionalAttributes[additionalAttributeIndex]).capitalizedString
                                                     andDetailLabel:((NSString *)self.report.type.additionalAttributes[additionalAttributeIndex]).length ? ((NSString *)self.report.type.additionalAttributes[additionalAttributeIndex]) : @"Not set"];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
                
            }break;
        }

    }else if (indexPath.section == ChangeStatusReportTableViewSectionIndex){
        NSString *updateStatusCellID = @"kCellIdentifierUpdateStatus";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:updateStatusCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:updateStatusCellID];
        }
        
        return cell;
    }

    
    return [[UITableViewCell alloc] init];
}

- (PhotoTableViewCell *)photoCellForTableView:(UITableView *)tableView{
    
    NSString *photoCellID = @"kCellIdentifierPhoto";
    
    PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:photoCellID];
    if (!cell) {
        cell = [[PhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:photoCellID];
    }
    
    cell.imageView.image = nil;
    cell.label.text = @"";
    if (self.report.thumbnailId) {
        
        //Download image by kinveyFileID
        [[DataHelper instance] loadImageByID:self.report.thumbnailId
                                   OnSuccess:^(UIImage *image){
                                       
                                       cell.imageView.image = image;
                                       [cell setNeedsDisplay];
                                       
                                   }onFailure:^(NSError *error){
                                       
                                       cell.label.text = error.localizedDescription;
                                   }];
        
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
    }else{
        cell.label.text = @"No thumbnail";
    }
    
    return cell;
}

- (UITableViewCell *)labelCellForTableView:(UITableView *)tableView withLabel:(NSString *)label andDetailLabel:(NSString *)detailLabel{
    
    NSString *labelCellID = @"kCellIdentifierRightDetail";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:labelCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:labelCellID];
    }
    
    cell.textLabel.text = label;
    cell.detailTextLabel.text = detailLabel;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == MainReportTableViewSectionIndex) {
        if (indexPath.row == PhotoReportTableViewRowIndex) {
            return PHOTO_ROW_HEIGHT;
        }else{
            return DEFAULT_ROW_HEIGHT;
        }
    }else if (indexPath.row == ChangeStatusReportTableViewSectionIndex){
        return DEFAULT_ROW_HEIGHT;
    }
    return DEFAULT_ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == MainReportTableViewSectionIndex) {
        if (indexPath.row == PhotoReportTableViewRowIndex) {
            [self performSegueWithIdentifier:kSegueIdentifierPushImageViewer
                                      sender:self];
        }
        if (indexPath.row == StateReportTableViewRowIndex) {
            if (self.canChangeState) {
                AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:@"Change status"];
                actionSheet.cancelHandler = ^(AHKActionSheet *actionSheet){
                    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:StateReportTableViewRowIndex
                                                                              inSection:MainReportTableViewSectionIndex]
                                                  animated:YES];
                };
                for (NSInteger i = 0; i < self.report.type.reportState.count; i++) {
                    NSString *state = self.report.type.reportState[i];
                    [actionSheet addButtonWithTitle:state
                                               type:AHKActionSheetButtonTypeDefault
                                            handler:^(AHKActionSheet *actionSheet){
                                                [self changeStatusTo:i];
                                            }];
                }
                [actionSheet show];
            }
        }
        
    }else if (indexPath.section == ChangeStatusReportTableViewSectionIndex){
        [DejalBezelActivityView activityViewForView:self.view.window withLabel:@"Update Status"];

        //Update entity in kinvey
        [[DataHelper instance] saveReport:self.report
                                OnSuccess:^(NSArray *reports){
                                    
                                    [DejalBezelActivityView removeView];
                                    [self.navigationController popViewControllerAnimated:YES];
                                    self.statusWasChanged = NO;
                                    
                                }onFailure:^(NSError *error){
                                    
                                    [DejalBezelActivityView removeView];
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                        message:error.localizedDescription
                                                                                       delegate:nil
                                                                              cancelButtonTitle:@"Cancel"
                                                                              otherButtonTitles:nil];
                                    [alertView show];
                                }];
    }
    
    
}

- (void)changeStatusTo:(NSInteger)statusIndex{
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:StateReportTableViewRowIndex
                                                              inSection:MainReportTableViewSectionIndex]
                                  animated:YES];
    
    if (self.currentServerState != statusIndex) {
        self.statusWasChanged = YES;
        self.report.state = [NSNumber numberWithInteger:statusIndex];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(resetStatus)];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:StateReportTableViewRowIndex
                                                                    inSection:MainReportTableViewSectionIndex]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        if (self.tableView.numberOfSections == 1) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        }else if (self.tableView.numberOfSections == 2){
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0
                                                                        inSection:ChangeStatusReportTableViewSectionIndex]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView endUpdates];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                  inSection:ChangeStatusReportTableViewSectionIndex]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }else{
        
        [self resetStatus];
    }
}

- (void)resetStatus{
    
    self.statusWasChanged = NO;
    self.report.state = [NSNumber numberWithInteger:self.currentServerState];
    self.navigationItem.leftBarButtonItem = self.defaultBackBarItem;
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:StateReportTableViewRowIndex
                                                                inSection:MainReportTableViewSectionIndex]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    if (self.tableView.numberOfSections == 2) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
}
@end
