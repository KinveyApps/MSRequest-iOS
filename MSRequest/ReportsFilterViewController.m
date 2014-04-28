//
//  ReportsFilterViewController.m
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

#import "ReportsFilterViewController.h"
#import "TypeOfReport.h"

#import "LabelTableViewCell.h"
#import "TextFieldTableViewCell.h"

typedef enum {
    OriginatorTableViewSectionIndex = 0,
    TypeTableViewSectionIndex,
    StateTableViewSectionIndex,
    LocationTableViewSectionIndex,
    DescriptionTableViewSectionIndex,
    FirstAdditionalAttributeTableViewSectionIndex
} TableViewSectionIndex;

@interface ReportsFilterViewController () <TextFieldTableViewCellDelegate>

@property (nonatomic, strong) NSDictionary *oldFilterOptions;
@property (nonatomic, strong) NSMutableDictionary *filterOptions;
@property (nonatomic, strong) TypeOfReport *type;
@property (nonatomic, weak) TextFieldTableViewCell *currentEditingTextFieldCell;

@end

@implementation ReportsFilterViewController

- (NSMutableDictionary *)filterOptions{
    if (!_filterOptions) {
        _filterOptions = [NSMutableDictionary dictionaryWithCapacity:FirstAdditionalAttributeTableViewSectionIndex + self.type.additionalAttributes.count];
    }
    return _filterOptions;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.filterOptions = [[DataHelper instance].filterOptions mutableCopy];
    if (self.filterOptions[TYPE_FILTER_KEY]) {
        for (TypeOfReport *type in [DataHelper instance].typesOfReport) {
            if ([type.entityId isEqualToString:self.filterOptions[TYPE_FILTER_KEY]]) {
                self.type = type;
                break;
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.type) {
        return FirstAdditionalAttributeTableViewSectionIndex + self.type.additionalAttributes.count;
    }else{
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case OriginatorTableViewSectionIndex:{
            return 2;
        }break;
            
        case TypeTableViewSectionIndex:{
            return [[DataHelper instance] typesOfReport].count;
        }break;
            
        case StateTableViewSectionIndex:{
            return self.type.reportState.count;
        }break;
            
        case LocationTableViewSectionIndex:{
            return 1;
        }break;
            
        case DescriptionTableViewSectionIndex:{
            return 1;
        }
            
        default:{
            NSInteger additionalAttributeIndex = section - FirstAdditionalAttributeTableViewSectionIndex;
            if ([self.type.additionalAttributesValidValues[additionalAttributeIndex] isKindOfClass:[NSArray class]]) {
                return ((NSArray *)self.type.additionalAttributesValidValues[additionalAttributeIndex]).count;
            }else{
                return 1;
            }
        }break;
    }
}

#define ALL_ORIGINATOR @"All Reports"
#define SELF_ORIGINATOR @"Only My Reports"
#define LOCATION_RADIUS_PLACEHOLDER @"Enter Filter Radius"
#define DESCRIPTION_FILTER_PLACEHOLDER @"Enter Filter Substring"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case OriginatorTableViewSectionIndex:{
            BOOL checkedSelf = [self.filterOptions[ORIGINATOR_FILTER_KEY] isEqualToString:[KCSUser activeUser].userId];
            if (indexPath.row) {
                return [self labelCellForTableView:tableView
                                         withLabel:SELF_ORIGINATOR
                                           checked:checkedSelf];
            }else{
                return [self labelCellForTableView:tableView
                                         withLabel:ALL_ORIGINATOR
                                           checked:!checkedSelf];
            }
        }break;
            
        case TypeTableViewSectionIndex:{
            TypeOfReport *typeForIndex = [DataHelper instance].typesOfReport[indexPath.row];
            return [self labelCellForTableView:tableView
                                     withLabel:typeForIndex.name
                                       checked:[self.filterOptions[TYPE_FILTER_KEY] isEqualToString:typeForIndex.entityId]];
        }break;
            
        case StateTableViewSectionIndex:{
            NSInteger currentFilterState = [(NSNumber *)self.filterOptions[STATE_FILTER_KEY] integerValue];
            return [self labelCellForTableView:tableView
                                     withLabel:self.type.reportState[indexPath.row]
                                       checked:self.filterOptions[STATE_FILTER_KEY] ? currentFilterState == indexPath.row : NO];
        }break;
            
        case LocationTableViewSectionIndex:{
            float currentRadiusDistance = [(NSNumber *)self.filterOptions[LOCATION_RADIUS_FILTER_KEY] floatValue];
            return [self textFieldCellForTableView:tableView
                                   withCurrentText:currentRadiusDistance ? [NSString stringWithFormat:@"%.000f", currentRadiusDistance] : @""
                                    andPlaceholder:LOCATION_RADIUS_PLACEHOLDER];
        }break;
            
        case DescriptionTableViewSectionIndex:{
            return [self textFieldCellForTableView:tableView
                                   withCurrentText:self.filterOptions[DESCRIPTION_FILTER_KEY]
                                    andPlaceholder:DESCRIPTION_FILTER_PLACEHOLDER];
        }
            
        default:{
            NSInteger additionalAttributeIndex = indexPath.section - FirstAdditionalAttributeTableViewSectionIndex;
            NSString *additionalAttributeName = self.type.additionalAttributes[additionalAttributeIndex];
            if ([self.type.additionalAttributesValidValues[additionalAttributeIndex] isKindOfClass:[NSArray class]]) {
                NSString *cellLabel = self.type.additionalAttributesValidValues[additionalAttributeIndex][indexPath.row];
                BOOL checked = [self.filterOptions[additionalAttributeName] isEqualToString:cellLabel];
                return [self labelCellForTableView:tableView
                                         withLabel:cellLabel
                                           checked:checked];
            }else{
                return [self textFieldCellForTableView:tableView
                                       withCurrentText:self.filterOptions[additionalAttributeName]
                                        andPlaceholder:DESCRIPTION_FILTER_PLACEHOLDER];
            }
        }break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case OriginatorTableViewSectionIndex:{
            return ORIGINATOR_FILTER_KEY;
        }break;
            
        case TypeTableViewSectionIndex:{
            return TYPE_FILTER_KEY;
        }break;
            
        case StateTableViewSectionIndex:{
            return STATE_FILTER_KEY;
        }break;
            
        case LocationTableViewSectionIndex:{
            return LOCATION_RADIUS_FILTER_KEY;
        }break;
            
        case DescriptionTableViewSectionIndex:{
            return DESCRIPTION_FILTER_KEY;
        }break;
        default:{
            NSInteger additionalAttributeIndex = section - FirstAdditionalAttributeTableViewSectionIndex;
            return self.type.additionalAttributes[additionalAttributeIndex];
        }break;
    }
}

- (LabelTableViewCell *)labelCellForTableView:(UITableView *)tableView withLabel:(NSString *)label checked:(BOOL)checked{
    
    NSString *labelCellID = @"kCellIdentifierCheckedLabel";
    
    LabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:labelCellID];
    if (!cell) {
        cell = [[LabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:labelCellID];
    }
    
    cell.label.text = label;
    if (checked) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
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
        cell.textField.text = @"";
    }
    cell.textField.delegate = cell;
    cell.delegate = self;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case OriginatorTableViewSectionIndex:{
            if (indexPath.row) {
                self.filterOptions[ORIGINATOR_FILTER_KEY] = [KCSUser activeUser].userId;
            }else{
                [self.filterOptions removeObjectForKey:ORIGINATOR_FILTER_KEY];
            }
        }break;
            
        case TypeTableViewSectionIndex:{
            TypeOfReport *typeForIndex = [DataHelper instance].typesOfReport[indexPath.row];
            self.type = typeForIndex;
            if ([self.filterOptions[TYPE_FILTER_KEY] isEqualToString:typeForIndex.entityId]) {
                [self.filterOptions removeObjectForKey:TYPE_FILTER_KEY];
                self.type = nil;
            }else{
                self.filterOptions[TYPE_FILTER_KEY] = typeForIndex.entityId;
            }
        }break;
            
        case StateTableViewSectionIndex:{
            if (self.filterOptions[STATE_FILTER_KEY] == [NSNumber numberWithInteger:indexPath.row]) {
                [self.filterOptions removeObjectForKey:STATE_FILTER_KEY];
            }else{
                self.filterOptions[STATE_FILTER_KEY] = [NSNumber numberWithInteger:indexPath.row];
            }
        }break;
            
        case LocationTableViewSectionIndex:{
        }break;
            
        case DescriptionTableViewSectionIndex:{
        }
            
        default:{
            NSInteger additionalAttributeIndex = indexPath.section - FirstAdditionalAttributeTableViewSectionIndex;
            NSString *additionalAttributeName = self.type.additionalAttributes[additionalAttributeIndex];
            if ([self.type.additionalAttributesValidValues[additionalAttributeIndex] isKindOfClass:[NSArray class]]) {
                if ([self.filterOptions[additionalAttributeName] isEqualToString:self.type.additionalAttributesValidValues[additionalAttributeIndex][indexPath.row]]) {
                    [self.filterOptions removeObjectForKey:additionalAttributeName];
                }else{
                    self.filterOptions[additionalAttributeName] = self.type.additionalAttributesValidValues[additionalAttributeIndex][indexPath.row];
                }
            }else{
            }
        }break;
    }
    [self.tableView reloadData];
}


#pragma mark - Text Field Table View Cell Delegate

- (void)textFieldTableViewCellDidBeginEditing:(TextFieldTableViewCell *)sender{
    self.currentEditingTextFieldCell = sender;
}

- (void)textFieldTableViewCellDidEndEditing:(TextFieldTableViewCell *)sender{
    
    NSIndexPath *indexPathEndEditingCell = [self.tableView indexPathForCell:sender];
    switch (indexPathEndEditingCell.section) {
        case LocationTableViewSectionIndex:{
            if (sender.textField.text.length) {
                [self.filterOptions removeObjectForKey:LOCATION_RADIUS_FILTER_KEY];
            }else{
                self.filterOptions[LOCATION_RADIUS_FILTER_KEY] = [NSNumber numberWithFloat:[sender.textField.text floatValue]];
            }
        }break;
            
        case DescriptionTableViewSectionIndex:{
            if (sender.textField.text.length) {
                [self.filterOptions removeObjectForKey:DESCRIPTION_FILTER_KEY];
            }else{
                self.filterOptions[DESCRIPTION_FILTER_KEY] = sender.textField.text;
            }
        }break;
            
        default:{
            NSString *additionalAttributeName = self.type.additionalAttributes[indexPathEndEditingCell.section - FirstAdditionalAttributeTableViewSectionIndex];
            if (sender.textField.text.length) {
                [self.filterOptions removeObjectForKey:additionalAttributeName];
            }else{
                self.filterOptions[additionalAttributeName] = sender.textField.text;
            }
        }break;
    }
    [self.tableView reloadData];
}

- (IBAction)doneButtonPressed:(id)sender {
    [DataHelper instance].filterOptions = self.filterOptions;
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)resetButtonPressed:(UIBarButtonItem *)sender {
    self.filterOptions = nil;
    [DataHelper instance].filterOptions = nil;
    self.type = nil;
    [self.tableView reloadData];
}

- (void)viewDidUnload
{

    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
