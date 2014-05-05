//
//  Report.m
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

#import "Report.h"

@implementation Report

- (NSDictionary *)hostToKinveyPropertyMapping{
    
    return @{@"entityId"                    : KCSEntityKeyId,
             @"metadata"                    : KCSEntityKeyMetadata,
             @"type"                        : @"type",
             @"valuesAdditionalAttributes"  : @"valuesAdditionalAttributes",
             @"imageId"                     : @"imageId",
             @"originator"                  : @"originator",
             @"state"                       : @"state",
             @"geoCoord"                    : KCSEntityKeyGeolocation,
             @"locationString"              : @"locationString",
             @"descriptionOfReport"         : @"descriptionOfReport",
             @"thumbnailId"                 : @"thumbnailId"};
}

+ (NSDictionary *)kinveyPropertyToCollectionMapping{
    
    return @{@"type"        : @"TypesOfReport",
             @"originator"  : KCSUserCollectionName};
}

+ (NSDictionary *)kinveyObjectBuilderOptions{
    
    return @{KCS_REFERENCE_MAP_KEY: @{@"type"   : [TypeOfReport class]}};
}

@end
