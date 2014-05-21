//
//  EditHomeSreenTableViewController.m
//  MSRequest
//
//  Created by Pavel Vilbik on 12.5.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

#import "EditHomeSreenTableViewController.h"
#import "DataHelper.h"
#import "TypeOfReport.h"
#import "SubtitleWithButtonTableViewCell.h"
#import "ReportsFilterViewController.h"
#import "ReportsRootViewController.h"

@interface EditHomeSreenTableViewController ()<SubtitleWithButtonTableViewCellDelegate>

@property (nonatomic, strong) NSArray *filterOptions;
@property (nonatomic, strong) NSArray *oldFilterOptions;

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.filterOptions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    if (options[LOCATION_RADIUS_FILTER_KEY]) {
        if (result.length){
            [result appendString:@", "];
        }
        [result appendString:[NSString stringWithFormat:@"near %.2fkm", [(NSNumber *)options[LOCATION_RADIUS_FILTER_KEY] floatValue]]];
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
    
    [self.delegate savePress:self];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
