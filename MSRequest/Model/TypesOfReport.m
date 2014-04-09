//
//  TypeReport.m
//  MSRequest
//
//  Created by Pavel Vilbik on 9.4.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

#import "TypesOfReport.h"

@implementation TypesOfReport

- (NSDictionary *)hostToKinveyPropertyMapping{
    
    return @{@"entityId"                : KCSEntityKeyId,
             @"name"                    : @"name",
             @"reportState"             : @"reportState",
             @"additionalAttributes"    : @"additionalAttributes"};
}

+ (NSDictionary *)kinveyObjectBuilderOptions{
    
    return @{KCS_REFERENCE_MAP_KEY  : @{@"reportState"          : [NSString class],
                                        @"additionalAttributes" : [NSString class]}};
}

@end
