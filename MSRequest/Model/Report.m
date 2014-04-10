//
//  Report.m
//  MSRequest
//
//  Created by Pavel Vilbik on 10.4.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

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
             @"descriptionOfReport"         : @"descriptionOfReport"};
}

+ (NSDictionary *)kinveyPropertyToCollectionMapping{
    
    return @{@"type"         : @"TypesOfReport",
             @"originator"   : KCSUserCollectionName};
}

+ (NSDictionary *)kinveyObjectBuilderOptions{
    
    return @{KCS_REFERENCE_MAP_KEY: @{@"type": [TypeOfReport class]}};
}

@end
