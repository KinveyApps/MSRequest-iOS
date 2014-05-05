//
//  Report.h
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

#import <Foundation/Foundation.h>
#import "TypeOfReport.h"

#define REPORT_KINVEY_COLLECTIONS_NAME @"Reports"

@interface Report : NSObject <KCSPersistable>

@property (nonatomic, copy) NSString *entityId;         //Kinvey entity _id
@property (nonatomic, retain) KCSMetadata *metadata;    //Kinvey metadata

@property (nonatomic, retain) TypeOfReport *type;
@property (nonatomic, retain) NSArray *valuesAdditionalAttributes;

@property (nonatomic, copy) NSString *imageId;
@property (nonatomic, retain) KCSUser *originator;
@property (nonatomic, retain) NSNumber *state;
@property (nonatomic, retain) CLLocation *geoCoord;
@property (nonatomic, copy) NSString *locationString;
@property (nonatomic, copy) NSString *descriptionOfReport;
@property (nonatomic, copy) NSString *thumbnailId;
@end
