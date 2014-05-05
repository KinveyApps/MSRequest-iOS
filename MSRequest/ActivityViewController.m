//
//  ActivityViewController.m
//  MSRequest
//
//  Created by Pavel Vilbik on 8.4.14.
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

#import "ActivityViewController.h"
#import "AuthenticationHelper.h"
#import "DataHelper.h"

@implementation ActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![AuthenticationHelper instance].isSignedIn) {
        [self performSegueWithIdentifier:@"kSegueIdentifierModalSingInView" sender:self];
    }
    
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    
    if ([AuthenticationHelper instance].isSignedIn) {
        
        [self preloadDataAndOpenReportRootView];
    }else{
        [self performSegueWithIdentifier:@"kSegueIdentifierModalSingInView" sender:self];
    }
}

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
                                                                                               
                                                                                               [self performSegueWithIdentifier:@"kSegueIdentifierPushReportRootView" sender:self];
                                                                                               
                                                                                           }onFailure:^(NSError *error){
                                                                                               
                                                                                               [self showSingInViewAndAlertWithError:error];
                                                                                           }];
                                                       }
                                                   }onFailure:^(NSError *error){
                                                       
                                                       [self showSingInViewAndAlertWithError:error];
                                                   }];
        }else{
            
            [self showSingInViewAndAlertWithError:errorOrNil];
        }
    }];
}

- (void)showSingInViewAndAlertWithError:(NSError *)error{
    
    [self performSegueWithIdentifier:@"kSegueIdentifierModalSingInView" sender:self];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
