//
//  ActivityViewController.m
//  MSRequest
//
//  Created by Pavel Vilbik on 8.4.14.
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

#import "ActivityViewController.h"
#import "AuthenticationHelper.h"
#import "DataHelper.h"

@implementation ActivityViewController


#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0.549 blue:0.5176 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    
    if ([AuthenticationHelper instance].isSignedIn) {
        [self preloadDataAndOpenReportRootView];
    }else{
        [self performSegueWithIdentifier:@"kSegueIdentifierModalSignInView"
                                  sender:self];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - Utility

- (void)preloadDataAndOpenReportRootView{
    
    //Kinvey: update user info from server
    [[KCSUser activeUser] refreshFromServer:^(NSArray *objectsOrNil, NSError *errorOrNil){
        
        if (!errorOrNil) {
            
            //Prelaod data from collections
            [[DataHelper instance] loadTypesOfReportUseCache:NO
                                                   OnSuccess:^(NSArray *typesOfReport){
                                                       
                                                       if (typesOfReport.count) {
                                                           
                                                           [[DataHelper instance] loadReportUseCache:NO
                                                                                           withQuery:nil
                                                                                           OnSuccess:^(NSArray *reports){
                                                                                               
                                                                                               NSString *userRoleID = [[KCSUser activeUser] getValueForAttribute:ID_USER_ROLE];
                                                                                               if (userRoleID.length) {
                                                                                                   [[DataHelper instance] updateUserRole:userRoleID
                                                                                                                               OnSuccess:^(NSArray *users){
                                                                                                                                   [self performSegueWithIdentifier:@"kSegueIdentifierPushReportRootView" sender:self];
                                                                                                                               }onFailure:^(NSError *error){
                                                                                                                                   
                                                                                                                                   [self showSignInViewAndAlertWithError:error];
                                                                                                                               }];
                                                                                               }else{
                                                                                                   [self showSignInViewAndAlertWithError:nil];
                                                                                               }
                                                                                               
                                                                                               
                                                                                           }onFailure:^(NSError *error){
                                                                                               
                                                                                               [self showSignInViewAndAlertWithError:error];
                                                                                           }];
                                                       }
                                                   }onFailure:^(NSError *error){
                                                       
                                                       [self showSignInViewAndAlertWithError:error];
                                                   }];
        }else{
            
            [self showSignInViewAndAlertWithError:errorOrNil];
        }
    }];
}

- (void)showSignInViewAndAlertWithError:(NSError *)error{
    
    [self performSegueWithIdentifier:@"kSegueIdentifierModalSignInView" sender:self];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
