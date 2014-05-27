//
//  EditHomeSreenTableViewController.m
//  MSRequest
//
//  Created by Pavel Vilbik on 12.5.14.
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

#import "EditHomeSreenTableViewController.h"
#import "DataHelper.h"
#import "TypeOfReport.h"
#import "SubtitleWithButtonTableViewCell.h"
#import "ReportsFilterViewController.h"
#import "ReportsRootViewController.h"
#import "TextFieldTableViewCell.h"

@interface EditHomeSreenTableViewController ()<SubtitleWithButtonTableViewCellDelegate, TextFieldTableViewCellDelegate>

@property (nonatomic, strong) NSArray *filterOptions;
@property (nonatomic, strong) NSArray *oldFilterOptions;
@property (nonatomic) CGFloat maxDistance;
@property (nonatomic) BOOL useLocationFilter;
@property (nonatomic, weak) TextFieldTableViewCell *distanceCell;

@end

@implementation EditHomeSreenTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.oldFilterOptions = [DataHelper instance].filterOptions;
    self.filterOptions = [DataHelper instance].filterOptions;
    self.maxDistance = [DataHelper instance].locationMaxDistanceFilter;
    if (self.maxDistance) {
        self.useLocationFilter = YES;
    }else{
        self.useLocationFilter = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.filterOptions = [DataHelper instance].filterOptions;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return self.filterOptions.count ? self.filterOptions.count : 1;
            break;
        case 1:
            return self.useLocationFilter ? 2 : 1;
            break;
            
        default:
            break;
    }
    return self.filterOptions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.section) {
        case 0:{
            
            if (self.filterOptions.count) {
                SubtitleWithButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kCellIdentifierTitleSubtitleWithButton"
                                                                                        forIndexPath:indexPath];
                
                if (!cell){
                    cell = [[SubtitleWithButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                  reuseIdentifier:@"kCellIdentifierTitleSubtitleWithButton"];
                }
                cell.title.text = [self titleWithOptions:self.filterOptions[indexPath.row]];
                cell.subtitle.text = [self subtitleWithOptions:self.filterOptions[indexPath.row]];
                cell.delegate = self;
                
                return cell;
            }else{
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kCellIdentifierBasic"];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:@"kCellIdentifierBasic"];
                }
                cell.textLabel.text = @"No filter options. Press \"+\" to add first";
                cell.textLabel.font = [UIFont systemFontOfSize:16];
                cell.textLabel.textColor = [UIColor grayColor];
                return cell;
            }
            
        }break;
        case 1:{
            
            if (indexPath.row) {
                TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kCellIdentifierTextField"];
                
                if (!cell) {
                    cell = [[TextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:@"kCellIdentifierTextField"];
                }
                if (self.maxDistance > 0) {
                    cell.textField.text = [NSString stringWithFormat:@"%.2f", self.maxDistance];
                }else{
                    cell.textField.text = nil;
                }
                cell.textField.placeholder = @"Max Distance";
                cell.delegate = self;
                cell.textField.delegate = cell;
                self.distanceCell = cell;
                
                return cell;
            }else{
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kCellIdentifierBasic"];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:@"kCellIdentifierBasic"];
                }
                
                cell.textLabel.text = @"Distance Filte";
                if (self.useLocationFilter) {
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }else{
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                }
                return cell;
            }
            
        }break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((indexPath.section == 1) && (indexPath.row == 0)) {
        self.useLocationFilter = !self.useLocationFilter;
        [tableView beginUpdates];
        if (!self.useLocationFilter) {
            self.maxDistance = 0;
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]]
                             withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]]
                             withRowAnimation:UITableViewRowAnimationMiddle];
        }
        [tableView endUpdates];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    if ((indexPath.section == 1) && (indexPath.row == 1)) {
        TextFieldTableViewCell *cell = (TextFieldTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell.textField becomeFirstResponder];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if ((indexPath.section == 0) && (!self.filterOptions.count)) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Filter Options";
            break;
        case 1:
            return @"Dictance";
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)titleWithOptions:(NSDictionary *)options{
    
    if (options[TYPE_FILTER_KEY]){
        for (TypeOfReport *type in [DataHelper instance].typesOfReport){
            if ([type.entityId isEqualToString:options[TYPE_FILTER_KEY]]){
                
                return [type.name capitalizedStringWithLocale:[NSLocale currentLocale]];
            }
        }
    }
    
    return @"All types";
}

- (NSString *)subtitleWithOptions:(NSDictionary *)options{
    
    NSMutableString *result = [NSMutableString string];
    
    TypeOfReport *currentType;
    for (TypeOfReport *type in [DataHelper instance].typesOfReport){
        if ([type.entityId isEqualToString:options[TYPE_FILTER_KEY]]){
            
            currentType = type;
        }
    }
    
    if (options[ORIGINATOR_FILTER_KEY]) {
        [result appendString:@"my reports"];
    }
    if (options[STATE_FILTER_KEY] && currentType) {
        if (result.length){
            [result appendString:@", "];
        }
        [result appendString:[NSString stringWithFormat:@"state: %@", currentType.reportState[[((NSNumber *)options[STATE_FILTER_KEY]) integerValue]]]];
    }
    if (currentType) {
        for (NSInteger i = 0; i < currentType.additionalAttributes.count; i++) {
            NSString *attribute = currentType.additionalAttributes[i];
            if (options[attribute]) {
                if (result.length){
                    [result appendString:@", "];
                }
                [result appendString:[NSString stringWithFormat:@"%@: %@", attribute, options[attribute]]];
            }
        }
    }
    
    return result;
}

- (void)rigthButtonPress:(SubtitleWithButtonTableViewCell *)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if (indexPath){
        NSMutableArray *options = [self.filterOptions mutableCopy];
        [options removeObjectAtIndex:indexPath.row];
        self.filterOptions = options;
        [DataHelper instance].filterOptions = options;
        [self.tableView reloadData];
    }
}

- (void)textFieldTableViewCellDidBeginEditing:(TextFieldTableViewCell *)sender{
    
}

- (void)textFieldTableViewCellDidEndEditing:(TextFieldTableViewCell *)sender{
    CGFloat maxDictance = [sender.textField.text floatValue];
    if (maxDictance > 0) {
        self.maxDistance = maxDictance;
    }else{
        self.maxDistance = 0;
    }
}

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"kSegueIdentifierAddFilterOption"]) {
        ReportsFilterViewController *destinationViewController = (ReportsFilterViewController *)segue.destinationViewController;
        destinationViewController.indexOfFilter = 1000;
    }else if ([segue.identifier isEqualToString:@"kSegueIdentifierEditFilterOption"]){
        ReportsFilterViewController *destinationViewController = (ReportsFilterViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        destinationViewController.indexOfFilter = indexPath.row;
    }
}

- (IBAction)cancelButtonPress:(UIBarButtonItem *)sender {
    
    [DataHelper instance].filterOptions = self.oldFilterOptions;
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}
- (IBAction)saveButtonPress:(UIBarButtonItem *)sender {

    if ([self.distanceCell.textLabel isFirstResponder]) {
        [self.distanceCell.textLabel resignFirstResponder];
    }
    [DataHelper instance].locationMaxDistanceFilter = self.maxDistance;
    [self.delegate savePress:self];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
