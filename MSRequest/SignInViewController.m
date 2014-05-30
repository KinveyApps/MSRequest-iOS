//
//  SignInViewController.m
//  MSRequest
//
//  Created by Igor Sapyanik on 22.01.14.
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
#import "SignInViewController.h"
#import "AuthenticationHelper.h"
#import "DejalActivityView.h"
#import "DataHelper.h"
#import "AHKActionSheet.h"

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstaraint;

@end


@implementation SignInViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
	[super viewWillAppear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardWillShow:)
                               name:UIKeyboardWillShowNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardWillHide:)
                               name:UIKeyboardWillHideNotification
                             object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    
	[super viewWillDisappear:animated];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)keyboardWillShow:(NSNotification *)notification{

    // get keyboard size and loctaion
	NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve curveType = [curve integerValue];
    UIViewAnimationOptions animationOptions = curveType << 16;
    
    [UIView animateWithDuration:[duration doubleValue]
						  delay:0
                        options:animationOptions
                     animations:^{
                         // set views with new info
						 self.bottomConstaraint.constant = 94;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

-(void)keyboardWillHide:(NSNotification *)notification{
    
    // get keyboard size and loctaion
	NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve curveType = [curve integerValue];
    UIViewAnimationOptions animationOptions = curveType << 16;
    
    [UIView animateWithDuration:[duration doubleValue]
						  delay:0
                        options:animationOptions
                     animations:^{
                         // set views with new info
						 self.bottomConstaraint.constant = 0;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (IBAction)pressedSignUp:(id)sender{
    
    void (^errorBlock)(NSError *) = ^(NSError *error){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription ? error.localizedDescription : @"Some wrong"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    };
    
	[DejalBezelActivityView activityViewForView:self.view.window];
    
    [[AuthenticationHelper instance] loginWithUsername:@"demoMSRequest"
                                              password:@"123456"
											 onSuccess:^{
                                                 
                                                 [[DataHelper instance] loadUserRolesUseCache:YES
                                                                                    OnSuccess:^(NSArray *userRoles){
                                                                                        
                                                                                        [[AuthenticationHelper instance] logout];
                                                                                        
                                                                                        [DejalActivityView removeView];
                                                                                        
                                                                                        AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:@"Select User Role"];
                                                                                        
                                                                                        for (UserRoles *role in userRoles) {
                                                                                            NSString *buttonTitle = [role.name capitalizedString];
                                                                                            [actionSheet addButtonWithTitle:buttonTitle
                                                                                                                       type:AHKActionSheetButtonTypeDefault
                                                                                                                    handler:^(AHKActionSheet *actionSheet){
                                                                                                                        
                                                                                                                        [DejalBezelActivityView activityViewForView:self.view.window];
                                                                                                                        
                                                                                                                        //Sign up new Kinvey user
                                                                                                                        [[AuthenticationHelper instance] signUpWithUsername:self.usernameField.text
                                                                                                                                                                   password:self.passwordField.text
                                                                                                                                                                  onSuccess:^{
                                                                                                                                                                      
                                                                                                                                                                      [[DataHelper instance] saveUserWithInfo:@{ID_USER_ROLE: role.kinveyId}
                                                                                                                                                                                                    OnSuccess:^(NSArray *users){
                                                                                                                                                                                                        
                                                                                                                                                                                                        [DejalActivityView removeView];
                                                                                                                                                                                                        
                                                                                                                                                                                                        [self dismissViewControllerAnimated:YES completion:nil];
                                                                                                                                                                                                        
                                                                                                                                                                                                        //Start push service
                                                                                                                                                                                                        [KCSPush registerForPush];
                                                                                                                                                                                                        
                                                                                                                                                                                                    }onFailure:^(NSError *error){
                                                                                                                                                                                                        
                                                                                                                                                                                                        [DejalBezelActivityView removeView];
                                                                                                                                                                                                        errorBlock(error);
                                                                                                                                                                                                    }];
                                                                                                                                                                      
                                                                                                                                                                  }
                                                                                                                                                                  onFailure:^(NSError *error){
                                                                                                                                                                      [DejalBezelActivityView removeView];
                                                                                                                                                                      
                                                                                                                                                                      errorBlock(error);
                                                                                                                                                                  }];
                                                                                                                    }];
                                                                                        }
                                                                                        [actionSheet show];
                                                                                    }onFailure:^(NSError *error){
                                                                                        [DejalActivityView removeView];
                                                                                        
                                                                                        errorBlock(error);
                                                                                    }];
                                             }
                                             onFailure:^(NSError *error){
                                                 [DejalActivityView removeView];
                                                 
                                                 errorBlock(error);
                                             }];
}

- (IBAction)pressedLogin:(id)sender{
    
	[DejalBezelActivityView activityViewForView:self.view.window];
    
    //Login Kinvey user
	[[AuthenticationHelper instance] loginWithUsername:self.usernameField.text
                                              password:self.passwordField.text
											 onSuccess:^{
                                                 
												 [DejalActivityView removeView];
                                                 
                                                 [self dismissViewControllerAnimated:YES completion:nil];
                                                 
                                                 //Start push service
                                                 [KCSPush registerForPush];
                                                 
											 }
											 onFailure:^(NSError *error) {
                                                 
												 [DejalBezelActivityView removeView];
                                                 
												 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                     message:error.localizedDescription ? error.localizedDescription : @"Some Wrong"
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"OK"
                                                                                           otherButtonTitles:nil];
                                                 [alertView show];
                                                 
											 }];
}

- (IBAction)demoPress:(id)sender {
    
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:@"Select Guest Role"];
    [actionSheet addButtonWithTitle:@"Employee"
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *actionSheet){
                                self.usernameField.text = @"demoEmployeeMSRequest";
                                self.passwordField.text = @"123456";
                                [self pressedLogin:sender];
                            }];
    [actionSheet addButtonWithTitle:@"Hardware Engineer"
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *actionSheet){
                                self.usernameField.text = @"demoHardwareEngineerMSRequest";
                                self.passwordField.text = @"123456";
                                [self pressedLogin:sender];
                            }];
    [actionSheet addButtonWithTitle:@"Software Engineer"
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *actionSheet){
                                self.usernameField.text = @"demoSoftwareEngineerMSRequest";
                                self.passwordField.text = @"123456";
                                [self pressedLogin:sender];
                            }];
    [actionSheet addButtonWithTitle:@"Security Engineer"
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *actionSheet){
                                self.usernameField.text = @"demoSecurityEngineerMSRequest";
                                self.passwordField.text = @"123456";
                                [self pressedLogin:sender];
                            }];
    [actionSheet addButtonWithTitle:@"Manager"
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *actionSheet){
                                self.usernameField.text = @"demoManagerMSRequest";
                                self.passwordField.text = @"123456";
                                [self pressedLogin:sender];
                            }];
    [actionSheet show];
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
	if (textField == self.usernameField) {
		[self.passwordField becomeFirstResponder];
	}
	else {
		[self.passwordField resignFirstResponder];
	}
    
	return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
