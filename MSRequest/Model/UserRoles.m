//
//  UserRoles.m
//  MSRequest
//
//  Created by Pavel Vilbik on 27.5.14.
//  Copyright (c) 2014 Kinvey, Inc. All rights reserved.
//

#import "UserRoles.h"
#import "TypeOfReport.h"

@implementation UserRoles

- (NSDictionary *)hostToKinveyPropertyMapping{
    
    //Kinvey: Mapping Function
    //      client property                     : backend column
    //      ------------------------------------:------------------------------------
    return @{@"kinveyId"                        : KCSEntityKeyId,
             @"metadata"                        : KCSEntityKeyMetadata,
             @"name"                            : @"name",
             @"availableTypesForReading"        : @"availableTypesForReading",
             @"availableTypesForCreating"       : @"availableTypesForCreating",
             @"availableTypesForChangingStatus" : @"availableTypesForChangingStatus"};
}

+ (NSDictionary *)kinveyPropertyToCollectionMapping{
    
    //    backend                     field name:collection name
    //------------------------------------------:-------------------
    return @{@"availableTypesForReading"        : @"TypesOfReport",
             @"availableTypesForCreating"       : @"TypesOfReport",
             @"availableTypesForChangingStatus" : @"TypesOfReport"};
}

+ (NSDictionary *)kinveyObjectBuilderOptions{
    
    //   Maps properties to object:                             property: class
    //------------------------------------------------------------------:------------------------
    return @{KCS_REFERENCE_MAP_KEY: @{@"availableTypesForReading"       : [TypeOfReport class],
                                      @"availableTypesForCreating"      : [TypeOfReport class],
                                      @"availableTypesForChangingStatus": [TypeOfReport class]}};
}

- (NSArray*) referenceKinveyPropertiesOfObjectsToSave{
    return @[@"availableTypesForReading",
             @"availableTypesForCreating",
             @"availableTypesForChangingStatus"];
}

@end
