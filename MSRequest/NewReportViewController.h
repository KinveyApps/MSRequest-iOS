//
//  NewReportViewController.h
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

#import <UIKit/UIKit.h>
#import "PickerTableViewController.h"
#import "MapViewController.h"
#import "DescriptionEditorViewController.h"

@class NewReportViewController;

@protocol NewReportViewControllerDelegate <NSObject>

- (void)submitFinish:(NewReportViewController *)sender;
- (void)needChangeToSize:(CGSize)size sender:(NewReportViewController *)sender;

@end

@interface NewReportViewController : UIViewController <UIImagePickerControllerDelegate, PickerTableViewControllerDelegate, MapViewControllerDelegate, DescriptionEditorViewControllerDelegate, UITextFieldDelegate, MapAnnotationDelegate>

@property (strong, nonatomic) Report *report;

@property (nonatomic, weak) id<NewReportViewControllerDelegate> delegate;

@end
