//
//  NotificationSettingsTableViewController.m
//  MSRequest
//
//  Created by Pavel Vilbik on 16.5.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

#import "NotificationSettingsTableViewController.h"
#import "DataHelper.h"
#import "TypeOfReport.h"
#import "DejalActivityView.h"

@interface NotificationSettingsTableViewController ()

@property (nonatomic, strong) NSMutableSet *reportTypeIDforNotification; //of NSString - id TypeOfReport

@end

@implementation NotificationSettingsTableViewController


#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style{
    
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Setters and Getters

- (NSMutableSet *)reportTypeIDforNotification{
    
    if (!_reportTypeIDforNotification) {
        _reportTypeIDforNotification = [NSMutableSet setWithCapacity:[DataHelper instance].typesOfReport.count];
    }
    return _reportTypeIDforNotification;
}


#pragma mark - View life cycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    //Update user info from server
    [[DataHelper instance] loadUserOnSuccess:^(NSArray *array){
        
        NSDictionary *userInfo = [array lastObject];
        if (userInfo[REPORT_TYPE_IDS_FOR_NOTIFICATION]) {
            self.reportTypeIDforNotification = userInfo[REPORT_TYPE_IDS_FOR_NOTIFICATION];
            [self.tableView reloadData];
        }
        
    }onFailure:nil];
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TABLE VIEW
#pragma mark - Data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // Return the number of rows in the section.
    return [DataHelper instance].typesOfReport.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kCellIdentifierBasic" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"kCellIdentifierBasic"];
    }
   
    TypeOfReport *type = (TypeOfReport *)[DataHelper instance].typesOfReport[indexPath.row];
    
    cell.textLabel.text = [type.name capitalizedString];
    if ([self.reportTypeIDforNotification containsObject:type.entityId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return @"Type of Reports";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    
    return @"If you select some type of report, you will get push notification of new report of this type.";
}


#pragma mark - Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TypeOfReport *type = (TypeOfReport *)[DataHelper instance].typesOfReport[indexPath.row];
    
    if ([self.reportTypeIDforNotification containsObject:type.entityId]) {
        [self.reportTypeIDforNotification removeObject:type.entityId];
    }else{
        [self.reportTypeIDforNotification addObject:type.entityId];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Actions

- (IBAction)cancelPress:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)savePress:(UIBarButtonItem *)sender {
    
    [DejalBezelActivityView activityViewForView:self.view.window
                                      withLabel:@"Save Settings"];
    
    //Save set of report type IDs in user info by attribute ArrayIDforPushNotification
    [[DataHelper instance] saveUserWithInfo:@{REPORT_TYPE_IDS_FOR_NOTIFICATION : self.reportTypeIDforNotification}
                                  OnSuccess:^(NSArray *array){
                                      
                                      [DejalBezelActivityView removeView];
                                      [self dismissViewControllerAnimated:YES
                                                               completion:nil];
                                      
                                  }onFailure:^(NSError *error){
                                      
                                      [DejalBezelActivityView removeView];
                                      [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:error.localizedDescription
                                                                 delegate:nil
                                                        cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles:nil] show];
                                  }];
}

@end
