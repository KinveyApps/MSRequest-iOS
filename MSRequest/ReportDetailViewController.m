//
//  ReportDetailViewController.m
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

#import "ReportDetailViewController.h"
#import "ImageScrollViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DataHelper.h"
#import "PhotoTableViewCell.h"
#import "LabelTableViewCell.h"
#import "DejalActivityView.h"

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

NSString *const kSegueIdentifierPushImageViewer = @"kSegueIdentifierPushImageViewer";

@interface ReportDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL statusWasChanged;
@property (nonatomic) NSInteger currentServerState;
@property (nonatomic, strong) UIBarButtonItem *defaultBackBarItem;
@end

@implementation ReportDetailViewController

#pragma mark - View lifecycle

// in viewWillAppear/Disappear, toggle nav bar hidden for smooth transition with parent vc
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = [self.report.type.name capitalizedString];
    self.currentServerState = [self.report.state integerValue];
    self.defaultBackBarItem = self.navigationItem.leftBarButtonItem;
}

- (void)viewDidUnload{

    [super viewDidUnload];
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
                LabelTableViewCell *cell = [self labelCellForTableView:tableView
                                                      withCurrentLabel:self.report.type.name
                                                        orDefaultLabel:@"No type"];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }break;
                
            case StateReportTableViewRowIndex:{
                LabelTableViewCell *cell = [self labelCellForTableView:tableView
                                                      withCurrentLabel:self.report.type.reportState[[self.report.state integerValue]]
                                                        orDefaultLabel: @"No state"];
                return cell;
            }break;
                
            case LocationReportTableViewRowIndex:{
                LabelTableViewCell *cell = [self labelCellForTableView:tableView
                                                      withCurrentLabel:self.report.locationString
                                                        orDefaultLabel:@"No locations"];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }break;
                
            case DescriptionReportTableViewRowIndex:{
                LabelTableViewCell *cell = [self labelCellForTableView:tableView
                                                      withCurrentLabel:self.report.descriptionOfReport
                                                        orDefaultLabel:@"No description"];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }break;
                
            default:{
                NSInteger additionalAttributeIndex = indexPath.row - FirstAdditionalAttributeReportTableViewRowIndex;
                LabelTableViewCell *cell = [self labelCellForTableView:tableView
                                                      withCurrentLabel:self.report.valuesAdditionalAttributes[additionalAttributeIndex]
                                                        orDefaultLabel:[NSString stringWithFormat:@"No %@", self.report.type.additionalAttributes[additionalAttributeIndex]]];
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

- (LabelTableViewCell *)labelCellForTableView:(UITableView *)tableView withCurrentLabel:(NSString *)currentLabel orDefaultLabel:(NSString *)defaultLabel{
    
    NSString *labelCellID = @"kCellIdentifierLabel";
    
    LabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:labelCellID];
    if (!cell) {
        cell = [[LabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:labelCellID];
    }
    
    if (currentLabel.length) {
        cell.label.text = currentLabel;
    }else{
        cell.label.text = defaultLabel;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == MainReportTableViewSectionIndex) {
        if (indexPath.row == PhotoReportTableViewRowIndex) {
            return 320;
        }else{
            return 44;
        }
    }else if (indexPath.row == ChangeStatusReportTableViewSectionIndex){
        return 44;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == MainReportTableViewSectionIndex) {
        if (indexPath.row == PhotoReportTableViewRowIndex) {
            [self performSegueWithIdentifier:kSegueIdentifierPushImageViewer
                                      sender:self];
        }
        if (indexPath.row == StateReportTableViewRowIndex) {
            UIActionSheet *imageSourceSelectorSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                                  delegate:self
                                                                         cancelButtonTitle:nil
                                                                    destructiveButtonTitle:nil
                                                                         otherButtonTitles:nil];
            for (NSString *state in self.report.type.reportState) {
                [imageSourceSelectorSheet addButtonWithTitle:state];
            }
            [imageSourceSelectorSheet addButtonWithTitle:@"Cancel"];
            imageSourceSelectorSheet.cancelButtonIndex = imageSourceSelectorSheet.numberOfButtons - 1;
            [imageSourceSelectorSheet showInView:self.view];
        }
    }else if (indexPath.section == ChangeStatusReportTableViewSectionIndex){
        [DejalBezelActivityView activityViewForView:self.view.window withLabel:@"Update Status"];

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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:StateReportTableViewRowIndex
                                                              inSection:MainReportTableViewSectionIndex]
                                  animated:YES];
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (self.currentServerState != buttonIndex) {
        self.statusWasChanged = YES;
        self.report.state = [NSNumber numberWithInteger:buttonIndex];
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
