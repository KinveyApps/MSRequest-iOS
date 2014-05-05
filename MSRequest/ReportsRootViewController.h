//
//  ReportsRootViewController.h
//  MSRequest
//
//  Created by Pavel Vilbik on 15.4.14.
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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomReportTableViewCell.h"
#import "ReportsFilterViewController.h"
#import "Report.h"

@class ReportModel;

@interface ReportsRootViewController : UIViewController <ReportsFilterViewControllerDelegate>

- (void)showDetailViewForReport:(Report *)report;

- (IBAction)logout:(id)sender;
@end
