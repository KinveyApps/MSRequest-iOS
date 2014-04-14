//
//  TypeReport.m
//  MSRequest
//
//  Created by Pavel Vilbik on 9.4.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

#import "TypeOfReport.h"

@implementation TypeOfReport

- (NSDictionary *)hostToKinveyPropertyMapping{
    
    return @{@"entityId"                        : KCSEntityKeyId,
             @"metadata"                        : KCSEntityKeyMetadata,
             @"name"                            : @"name",
             @"reportState"                     : @"reportState",
             @"additionalAttributes"            : @"additionalAttributes",
             @"additionalAttributesValidValues" : @"additionalAttributesValidValues"};
}

@end
