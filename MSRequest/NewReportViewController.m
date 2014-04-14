//
//  NewReportViewController.m
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

#define MAX_IMAGE_BUTTON_WIDTH      280.0f
#define MAX_IMAGE_BUTTON_HEIGHT     160.0f

typedef enum {
    NewReportTextFieldTypeCategory = 0,
    NewReportTextFieldTypeLocation,
    NewReportTextFieldTypeDescription
} NewReportTextFieldType;

typedef enum {
    PhotoNewReportTableViewRowIndex = 0,
    TypeNewReportTableViewRowIndex,
    StateNewReportTableViewRowIndex,
    LocationNewReportTableViewRowIndex,
    DescriptionNewReportTableViewRowIndex,
    FirstAdditionalAttributeNewReportTableViewRowIndex
} NewReportTableViewRowIndex;

@interface NewReportViewController() <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, TextFieldTableViewCellDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) MapAnnotation *reportAnnotation;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic, strong) CLLocationManager* locationManager;

@property (nonatomic, strong) NSMutableArray *additionalAttributedValues;
@property (nonatomic, strong) NSArray *arrayForPicker;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) TextFieldTableViewCell *currentEditingTextFieldCell;
@property (strong, nonatomic) NSIndexPath *currentSelectedIndexPath;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTableViewConstraint;

@property (strong, nonatomic) NSArray *typeOfReportNames;

@end

@implementation NewReportViewController


#pragma mark - Setters and Getters

- (NSArray *)typeOfReportNames{
    if ([DataHelper instance].typesOfReport) {
        
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


#pragma mark - Table View
#pragma mark - Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (self.report.type) {
            return FirstAdditionalAttributeNewReportTableViewRowIndex + self.report.type.additionalAttributes.count;
        }else{
            return 2;
        }
    }else if (section == 1){
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
    
    if (indexPath.section == 0) {
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

    }else if (indexPath.section == 1){
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
        cell.imageView.image = self.image;
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
    }else{
        cell.imageView.image = [UIImage imageNamed:@"photo_icon"];
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
    if (indexPath.section == 0) {
        if (indexPath.row == PhotoNewReportTableViewRowIndex) {
            return 200;
        }else{
            return 44;
        }
    }else if (indexPath.section == 1){
        return 44;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        self.currentSelectedIndexPath = indexPath;
        
        switch (indexPath.row) {
                
            case PhotoNewReportTableViewRowIndex:{
                UIActionSheet *imageSourceSelectorSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                                      delegate:self
                                                                             cancelButtonTitle:@"Cancel"
                                                                        destructiveButtonTitle:nil
                                                                             otherButtonTitles:@"Take Photo", @"Choose Existing Photo", nil];
                [imageSourceSelectorSheet showInView:self.view];
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

    }else if (indexPath.section == 1){
        self.report.metadata = [[KCSMetadata alloc] init];
        self.report.valuesAdditionalAttributes = self.additionalAttributedValues;
        
        UIImage *smallImage = [self.image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(640, 640) interpolationQuality:kCGInterpolationDefault];
        
        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Upload Image"];
        
        [[DataHelper instance] saveImage:smallImage
                               OnSuccess:^(NSString *imageID){
                                   self.report.imageId = imageID;
                                   [DejalBezelActivityView removeView];
                                   [DejalBezelActivityView activityViewForView:self.view withLabel:@"Submit Report"];
                                   
                                   [[DataHelper instance] saveReport:self.report
                                                           OnSuccess:^(NSArray *reports){
                                                               [DejalBezelActivityView removeView];
                                                               [self.navigationController popViewControllerAnimated:YES];
                                                           }onFailure:nil];
                               }onFailure:nil];

    }
    
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








- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = (id)self;
        _imagePickerController.allowsEditing = NO;
    }
    return _imagePickerController;
}


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

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)viewDidLoad
{
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


#pragma mark - UIActionSheetDelegate

- (IBAction)imageSourceSelectionButtonPressed {    
    UIActionSheet *imageSourceSelectorSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                                          delegate:self 
                                                                 cancelButtonTitle:@"Cancel" 
                                                            destructiveButtonTitle:nil 
                                                                 otherButtonTitles:@"Take Photo", @"Choose Existing Photo", nil];
    [imageSourceSelectorSheet showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
        
    switch (buttonIndex) {
        case 0: // take photo
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else {
                NSLog(@"Camera not available");
                return;
            }
            break;
        case 1: // choose existing photo
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            else {
                NSLog(@"No photos available");
                return;
            }
            break;
    }
    
//    [self presentModalViewController:self.imagePickerController animated:YES];
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
    [self.navigationController setNavigationBarHidden:YES animated:NO]; // override showing of nav bar
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

    self.report.locationString = annotation.subtitle;
    self.report.geoCoord = [CLLocation locationFromKinveyValue:CLLocationCoordinate2DToKCS(annotation.coordinate)];
//    self.report.location = annotation.coordinate;

    [self.tableView reloadData];
}

#pragma mark - DescriptionEditorViewControllerDelegate

- (void)descriptionEditorFinishedEditingWithText:(NSString *)description {
    [self.navigationController popViewControllerAnimated:YES];
    self.report.descriptionOfReport = description;
    [self.tableView reloadData]; 
//    NSLinguisticTagger* tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:@[] options:0];
//    [tagger setString:description];
//    NSRange r = [tagger sentenceRangeForRange:NSMakeRange(0, 1)];
//    self.report.summary = [description substringWithRange:r];

}

-(NSString *)documentsDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    return documentsDirectoryPath;
} 

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // store new image in report
    UIImage *newImage = info[UIImagePickerControllerOriginalImage];
    
    self.image = newImage;
    
    // adjust button size according to new image aspect ratio and max dimensions
    CGSize newImagePickerButtonSize = newImage.size;
    if (newImagePickerButtonSize.height > MAX_IMAGE_BUTTON_HEIGHT) {
        newImagePickerButtonSize.height = MAX_IMAGE_BUTTON_HEIGHT;
        newImagePickerButtonSize.width = (newImage.size.width/newImage.size.height) * newImagePickerButtonSize.height;
    }
    if (newImagePickerButtonSize.width > MAX_IMAGE_BUTTON_WIDTH) {
        newImagePickerButtonSize.width = MAX_IMAGE_BUTTON_WIDTH;
        newImagePickerButtonSize.height = (newImage.size.height/newImage.size.width) * newImagePickerButtonSize.width;
    }
    [self.tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [self dismissModalViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Location
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    
    self.reportAnnotation = [[MapAnnotation alloc] initWithCoordinate:location.coordinate
                                                                title:@"Report Location"];
    self.reportAnnotation.delegate = self;
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - MapAnnotationDelegate

- (void)mapAnnotationFinishedReverseGeocoding:(MapAnnotation *)annotation {
    // update text field with new location
        self.report.locationString = annotation.subtitle;
        self.report.geoCoord = [CLLocation locationFromKinveyValue:CLLocationCoordinate2DToKCS(annotation.coordinate)];

        [self.tableView reloadData];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submitButtonPressed:(id)sender {
    self.report.metadata = [[KCSMetadata alloc] init];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        UIImage *smallImage = [self.image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(640, 640) interpolationQuality:kCGInterpolationDefault];
        
        [[DataHelper instance] saveImage:smallImage
                               OnSuccess:^(NSString *imageID){
                                   self.report.imageId = imageID;
                                   
                                   [[DataHelper instance] saveReport:self.report
                                                           OnSuccess:^(NSArray *reports){
                                                               [self dismissViewControllerAnimated:YES completion:nil];
                                                           }onFailure:nil];
                               }onFailure:nil];
    });
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
