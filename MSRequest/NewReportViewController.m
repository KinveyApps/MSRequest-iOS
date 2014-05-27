//
//  NewReportViewController.m
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

#import "NewReportViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "MapAnnotation.h"
#import "UIImage+Resize.h"
#import "AppDelegate.h"
#import "DataHelper.h"
#import "DejalActivityView.h"

#import "PhotoTableViewCell.h"
#import "LabelTableViewCell.h"
#import "TextFieldTableViewCell.h"

#import "AHKActionSheet.h"

typedef enum {
    PhotoNewReportTableViewRowIndex = 0,
    TypeNewReportTableViewRowIndex,
    StateNewReportTableViewRowIndex,
    LocationNewReportTableViewRowIndex,
    DescriptionNewReportTableViewRowIndex,
    FirstAdditionalAttributeNewReportTableViewRowIndex
} NewReportTableViewRowIndex;

typedef enum {
    MainNewReportTableViewSectionIndex = 0,
    SubmitNewReportTableViewSectionIndex
} NewReportTableViewSectionIndex;

#define DEFAULT_ROW_HEIGHT 44;
#define PHOTO_ROW_HEIGHT 320;

@interface NewReportViewController() <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, TextFieldTableViewCellDelegate>

@property (strong, nonatomic) MapAnnotation *reportAnnotation;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *thumbnail;
@property (nonatomic, strong) CLLocationManager* locationManager;

@property (strong, nonatomic) NSArray *typeOfReportNames;
@property (nonatomic, strong) NSMutableArray *additionalAttributedValues;
@property (nonatomic, strong) NSArray *arrayForPicker;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) TextFieldTableViewCell *currentEditingTextFieldCell;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) NSIndexPath *currentSelectedIndexPath;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTableViewConstraint;

@end

@implementation NewReportViewController


#pragma mark - Setters and Getters

- (NSArray *)typeOfReportNames{
    
    if ([DataHelper instance].typesOfReport) {
        
        //Create array of type name
        if (!_typeOfReportNames.count) {
            NSMutableArray *typeNames = [NSMutableArray arrayWithCapacity:[DataHelper instance].typesOfReport.count];
            
            for (TypeOfReport *type in [DataHelper instance].typesOfReport) {
                [typeNames addObject:type.name];
            }
            _typeOfReportNames = typeNames;
            
            return _typeOfReportNames;
        }
        return _typeOfReportNames;
    }
    return nil;
}

- (UIImagePickerController *)imagePickerController {
    
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = (id)self;
        _imagePickerController.allowsEditing = NO;
    }
    
    return _imagePickerController;
}


#pragma mark - Table View
#pragma mark - Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == MainNewReportTableViewSectionIndex) {
        if (self.report.type) {
            
            return FirstAdditionalAttributeNewReportTableViewRowIndex + self.report.type.additionalAttributes.count;
            
        }else{
            
            return 2;
        }
    }else if (section == SubmitNewReportTableViewSectionIndex){
        if (self.report.type && self.image) {
            
            return 1;
        }
    }
    return  0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.report.type && self.image) {
        return 2;
    }else{
        return 1;
    }
}


#pragma mark - Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == MainNewReportTableViewSectionIndex) {
        switch (indexPath.row) {
                
            case PhotoNewReportTableViewRowIndex:{
                PhotoTableViewCell *cell = [self photoCellForTableView:tableView];
                
                return cell;
            }break;
                
            case TypeNewReportTableViewRowIndex:{
                LabelTableViewCell *cell = [self labelCellForTableView:tableView
                                                      withCurrentLabel:self.report.type.name
                                                        orDefaultLabel:@"Selecte type"];
                return cell;
            }break;
                
            case StateNewReportTableViewRowIndex:{
                LabelTableViewCell *cell = [self labelCellForTableView:tableView
                                                      withCurrentLabel:self.report.type.reportState[[self.report.state integerValue]]
                                                        orDefaultLabel: @"Selecte state"];
                return cell;
            }break;
                
            case LocationNewReportTableViewRowIndex:{
                LabelTableViewCell *cell = [self labelCellForTableView:tableView
                                                      withCurrentLabel:self.report.locationString
                                                        orDefaultLabel:@"Selecte locations"];
                return cell;
            }break;
                
            case DescriptionNewReportTableViewRowIndex:{
                LabelTableViewCell *cell = [self labelCellForTableView:tableView
                                                      withCurrentLabel:self.report.descriptionOfReport
                                                        orDefaultLabel:@"Tap to add description"];
                return cell;
            }break;
                
            default:{
                NSInteger additionalAttributeIndex = indexPath.row - FirstAdditionalAttributeNewReportTableViewRowIndex;
                NSString *additionalAttributeValue = (NSString *)self.additionalAttributedValues[additionalAttributeIndex];
                
                if ([self.report.type.additionalAttributesValidValues[additionalAttributeIndex] isKindOfClass:[NSArray class]]) {
                    LabelTableViewCell *cell = [self labelCellForTableView:tableView
                                                          withCurrentLabel:additionalAttributeValue
                                                            orDefaultLabel:[NSString stringWithFormat:@"Selecte %@", self.report.type.additionalAttributes[additionalAttributeIndex]]];
                    return cell;
                }else{
                    TextFieldTableViewCell *cell = [self textFieldCellForTableView:tableView
                                                                   withCurrentText:additionalAttributeValue
                                                                    andPlaceholder:[NSString stringWithFormat:@"Enter %@", self.report.type.additionalAttributes[additionalAttributeIndex]]];
                    return cell;
                }
                
            }break;
        }

    }else if (indexPath.section == SubmitNewReportTableViewSectionIndex){
        
        NSString *photoCellID = @"kCellIdentifierSubmit";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:photoCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:photoCellID];
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
    
    if (self.image) {
        cell.imageView.image = self.thumbnail;
        cell.label.text = @"";
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
    }else{
        cell.imageView.image = [UIImage imageNamed:@"photo_icon"];
        cell.label.text = @"Tap to add or take a photo";
        cell.imageView.contentMode = UIViewContentModeCenter;
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

- (TextFieldTableViewCell *)textFieldCellForTableView:(UITableView *)tableView withCurrentText:(NSString *)currentText andPlaceholder:(NSString *)placeholder{
    
    NSString *textFieldCellID = @"kCellIdentifierTextField";
    
    TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:textFieldCellID];
    if (!cell) {
        cell = [[TextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textFieldCellID];
    }
    
    if (currentText.length) {
        cell.textField.text = currentText;
    }else{
        cell.textField.placeholder = placeholder;
    }
    cell.textField.delegate = cell;
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == MainNewReportTableViewSectionIndex) {
        
        if (indexPath.row == PhotoNewReportTableViewRowIndex) {
            return PHOTO_ROW_HEIGHT;
        }else{
            return DEFAULT_ROW_HEIGHT;
        }
        
    }else if (indexPath.section == SubmitNewReportTableViewSectionIndex){
        return DEFAULT_ROW_HEIGHT;
    }
    return DEFAULT_ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == MainNewReportTableViewSectionIndex) {
        self.currentSelectedIndexPath = indexPath;
        
        switch (indexPath.row) {
                
            case PhotoNewReportTableViewRowIndex:{
                AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:@"Add Image"];
                
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    [actionSheet addButtonWithTitle:@"Take Photo"
                                              image:[UIImage imageNamed:@"GetFoto"]
                                               type:AHKActionSheetButtonTypeDefault
                                            handler:^(AHKActionSheet *actionSheet){
                                                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                [self presentViewController:self.imagePickerController animated:YES completion:nil];
                                                [self.navigationController setNavigationBarHidden:YES animated:NO];
                                            }];
                }
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    [actionSheet addButtonWithTitle:@"Choose Existing Photo"
                                              image:[UIImage imageNamed:@"GetFromAlbum"]
                                               type:AHKActionSheetButtonTypeDefault
                                            handler:^(AHKActionSheet *actionSheet){
                                                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                [self presentViewController:self.imagePickerController animated:YES completion:nil];
                                                [self.navigationController setNavigationBarHidden:YES animated:NO];
                                            }];
                }
                [actionSheet show];
            }break;
                
            case LocationNewReportTableViewRowIndex:{
                [self performSegueWithIdentifier:@"kSegueIdentifierPushMap" sender:self];
            }break;
                
            case DescriptionNewReportTableViewRowIndex:{
                [self performSegueWithIdentifier:@"kSegueIdentifierPushDescription" sender:self];
            }break;
                
            default:{
                if (indexPath.row == TypeNewReportTableViewRowIndex) self.arrayForPicker = self.typeOfReportNames;
                if (indexPath.row == StateNewReportTableViewRowIndex) self.arrayForPicker = self.report.type.reportState;
                if (indexPath.row >= FirstAdditionalAttributeNewReportTableViewRowIndex) self.arrayForPicker = self.report.type.additionalAttributesValidValues[indexPath.row - FirstAdditionalAttributeNewReportTableViewRowIndex];
                if ((indexPath.row < FirstAdditionalAttributeNewReportTableViewRowIndex) ||
                    [self.report.type.additionalAttributesValidValues[indexPath.row - FirstAdditionalAttributeNewReportTableViewRowIndex] isKindOfClass:[NSArray class]]) {
                    [self performSegueWithIdentifier:@"kSegueIdentifierPushPickerTable" sender:self];
                }
            }break;
        }

    }else if (indexPath.section == SubmitNewReportTableViewSectionIndex){
        [DejalBezelActivityView activityViewForView:self.view.window withLabel:@"Upload Image"];
        
        //save full image in kinvey
        [[DataHelper instance] saveImage:self.image
                               OnSuccess:^(NSString *imageID){
                                   
                                   self.report.imageId = imageID;
                                   
                                   //save thumbnail image in kinvey
                                   [[DataHelper instance] saveImage:self.thumbnail
                                                          OnSuccess:^(NSString *thumbnailID){
                                                              self.report.thumbnailId = thumbnailID;
                                                              
                                                              [DejalBezelActivityView removeView];
                                                              [DejalBezelActivityView activityViewForView:self.view withLabel:@"Submit Report"];
                                                              
                                                              self.report.metadata = [[KCSMetadata alloc] init];
                                                              [self.report.metadata setGloballyReadable:YES];
                                                              [self.report.metadata setGloballyWritable:YES];
                                                              self.report.valuesAdditionalAttributes = self.additionalAttributedValues;
                                                              if (!self.report.state) {
                                                                  self.report.state = @0;
                                                              }
                                                              self.report.originator = [KCSUser activeUser];
                                                              
                                                              //add new report in kinvey
                                                              [[DataHelper instance] saveReport:self.report
                                                                                      OnSuccess:^(NSArray *reports){
                                                                                          
                                                                                          [DejalBezelActivityView removeView];
                                                                                          [self.delegate submitFinish:self];
                                                                                          [self.navigationController popViewControllerAnimated:YES];
                                                                                          
                                                                                      }onFailure:^(NSError *error){
                                                                                          [self submitError:error];
                                                                                      }];
                                                              
                                                          }onFailure:^(NSError *error){
                                                              [self submitError:error];
                                                          }];
                                   
                               }onFailure:^(NSError *error){
                                   [self submitError:error];
                               }];
    }
    
}

- (void)submitError:(NSError *)error{
    
    [DejalBezelActivityView removeView];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
    [alertView show];
}


#pragma mark - Text Field Table View Cell Delegate

- (void)textFieldTableViewCellDidBeginEditing:(TextFieldTableViewCell *)sender{
    self.currentEditingTextFieldCell = sender;
}

- (void)textFieldTableViewCellDidEndEditing:(TextFieldTableViewCell *)sender{
    
    if (sender.textField.text.length) {
        NSIndexPath *indexPathEndEditingCell = [self.tableView indexPathForCell:sender];
        
        self.additionalAttributedValues[indexPathEndEditingCell.row - FirstAdditionalAttributeNewReportTableViewRowIndex] = sender.textField.text;
    }
}


#pragma mark - Keyboard Notification

- (void)keyboardShow:(NSNotification *)notification{
    
    CGRect keyboardOriginFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.bottomTableViewConstraint.constant = keyboardOriginFrame.size.height;
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardHide:(NSNotification *)nofification{
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.bottomTableViewConstraint.constant = 0;
                         [self.view layoutIfNeeded];
                     }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"kSegueIdentifierPushPickerTable"]) {
        ((PickerTableViewController *)segue.destinationViewController).delegate = self;
        ((PickerTableViewController *)segue.destinationViewController).cellTitles = self.arrayForPicker;
        
        switch (self.currentSelectedIndexPath.row) {
                
            case TypeNewReportTableViewRowIndex:{
                ((PickerTableViewController *)segue.destinationViewController).selectedRow = [[DataHelper instance].typesOfReport indexOfObject:self.report.type];
            }break;
                
            case StateNewReportTableViewRowIndex:{
                    ((PickerTableViewController *)segue.destinationViewController).selectedRow = [self.report.state integerValue];
            }break;
                
            default:{
                NSInteger additionalAttributeIndex = self.currentSelectedIndexPath.row - FirstAdditionalAttributeNewReportTableViewRowIndex;
                NSString *additionalAttributeValue = (NSString *)self.additionalAttributedValues[additionalAttributeIndex];
                
                if (additionalAttributeValue.length) {
                    NSInteger pickerIndex = [self.report.type.additionalAttributesValidValues[additionalAttributeIndex] indexOfObject:additionalAttributeValue];
                    ((PickerTableViewController *)segue.destinationViewController).selectedRow = pickerIndex;
                }else{
                    ((PickerTableViewController *)segue.destinationViewController).selectedRow = -1;
                }
            }break;
        }
    }
    else if ([segue.identifier isEqualToString:@"kSegueIdentifierPushMap"]) {
        ((MapViewController *)segue.destinationViewController).delegate = self;
        ((MapViewController *)segue.destinationViewController).reportAnnotation = self.reportAnnotation;
    }
    else if ([segue.identifier isEqualToString:@"kSegueIdentifierPushDescription"]) {
        ((DescriptionEditorViewController *)segue.destinationViewController).delegate = self;
        ((DescriptionEditorViewController *)segue.destinationViewController).description = self.report.descriptionOfReport;
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    self.report = [[Report alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    self.navigationItem.hidesBackButton = YES;
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [super viewWillDisappear:animated];
}



- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - PickerTableViewControllerDelegate

- (void)pickerTableViewController:(PickerTableViewController *)picker selectedRow:(NSInteger)row {
    [self.navigationController popViewControllerAnimated:YES];
    
    switch (self.currentSelectedIndexPath.row) {
            
        case TypeNewReportTableViewRowIndex:{
            if (self.report.type != [DataHelper instance].typesOfReport[row]) {
                self.report.type = [DataHelper instance].typesOfReport[row];
                [self clearAdditionalAttributes];
                [self.tableView reloadData];
            }
        }break;
            
        case StateNewReportTableViewRowIndex:{
            if (self.report.state != self.report.type.reportState[row]) {
                self.report.state = @(row);
                [self.tableView reloadData];
            }
        }break;
            
        default:{
            NSInteger additionalAttributeIndex = self.currentSelectedIndexPath.row - FirstAdditionalAttributeNewReportTableViewRowIndex;
            NSString *additionalAttributeValue = (NSString *)self.additionalAttributedValues[additionalAttributeIndex];
            
            if (![additionalAttributeValue isEqualToString:self.report.type.additionalAttributesValidValues[additionalAttributeIndex][row]]) {
                self.additionalAttributedValues[additionalAttributeIndex] = self.report.type.additionalAttributesValidValues[additionalAttributeIndex][row];
                [self.tableView reloadData];
            }
        }break;
    }
}

- (void)clearAdditionalAttributes{
    self.additionalAttributedValues = [[NSMutableArray alloc] initWithCapacity:self.report.type.additionalAttributes.count];
    
    for (NSInteger i = 0; i < self.report.type.additionalAttributes.count; i++) {
        [self.additionalAttributedValues addObject:@""];
    }
}


#pragma mark - MapViewControllerDelegate

- (void)mapViewControllerDoneButtonPressedWithAnnotation:(MapAnnotation *)annotation {
    [self.navigationController popViewControllerAnimated:YES];

    if (annotation.subtitle.length) {
        self.report.locationString = annotation.subtitle;
    }else{
        self.report.locationString = [NSString stringWithFormat:@"%.4f°, %.4f°", annotation.coordinate.longitude, annotation.coordinate.latitude];
    }
    self.report.geoCoord = [CLLocation locationFromKinveyValue:CLLocationCoordinate2DToKCS(annotation.coordinate)];

    [self.tableView reloadData];
}


#pragma mark - DescriptionEditorViewControllerDelegate

- (void)descriptionEditorFinishedEditingWithText:(NSString *)description {
    [self.navigationController popViewControllerAnimated:YES];
    
    self.report.descriptionOfReport = description;
    [self.tableView reloadData];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.image = info[UIImagePickerControllerOriginalImage];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self.image resizedImage:self.image.size interpolationQuality:kCGInterpolationNone];
        UIImage *thumbnail = [self.image thumbnailImage:640 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = image;
            self.thumbnail = thumbnail;
            [self.tableView reloadData];
        });
        
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Location

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    
    [DataHelper instance].currentLocation = location;
    
    self.reportAnnotation = [[MapAnnotation alloc] initWithCoordinate:location.coordinate
                                                                title:@"Report Location"];
    self.reportAnnotation.delegate = self;
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - MapAnnotationDelegate

- (void)mapAnnotationFinishedReverseGeocoding:(MapAnnotation *)annotation {
    // update text field with new location
    if (annotation.subtitle.length) {
        self.report.locationString = annotation.subtitle;
    }else{
        self.report.locationString = [NSString stringWithFormat:@"%.4f°, %.4f°", annotation.coordinate.longitude, annotation.coordinate.latitude];
    }
    self.report.geoCoord = [CLLocation locationFromKinveyValue:CLLocationCoordinate2DToKCS(annotation.coordinate)];
    
    [self.tableView reloadData];
}


#pragma mark - Actions

- (IBAction)cancelButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
