//
//  Report.m
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

#import "Report.h"

@implementation Report

- (NSDictionary *)hostToKinveyPropertyMapping{
    
    //Kinvey: Mapping Function
    //      client property                 : backend column
    //      --------------------------------:---------------------------------------
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
    
    //    backend field name:collection name
    //----------------------:---------------------------
    return @{@"type"        : @"TypesOfReport",
             @"originator"  : KCSUserCollectionName};
}

+ (NSDictionary *)kinveyObjectBuilderOptions{
    
    //   Maps properties to object:     property: class
    //------------------------------------------:-------------------
    return @{KCS_REFERENCE_MAP_KEY: @{@"type"   : [TypeOfReport class]}};
}

@end
