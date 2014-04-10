//
//  ActivityViewController.m
//  MSRequest
//
//  Created by Pavel Vilbik on 8.4.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

#import "ActivityViewController.h"
#import "AuthenticationHelper.h"
#import "DataHelper.h"

@interface ActivityViewController ()

@end

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
    
    if ([AuthenticationHelper instance].isSignedIn) {
        
        [self preloadDataAndOpenReportRootView];
    }
}

- (void)preloadDataAndOpenReportRootView{
    
    [[KCSUser activeUser] refreshFromServer:^(NSArray *objectsOrNil, NSError *errorOrNil){
        
        if (!errorOrNil) {
            
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
