//
//  UserRoles.h
//  MSRequest
//
//  Created by Pavel Vilbik on 27.5.14.
//  Copyright (c) 2014 Kinvey, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USER_ROLES_KINVEY_COLLECTIONS_NAME @"UserRoles"

@interface UserRoles : NSObject <KCSPersistable>

@property (nonatomic, retain) NSString *kinveyId;
@property (nonatomic, retain) KCSMetadata *metadata;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSSet *availableTypesForReading;
@property (nonatomic, retain) NSSet *availableTypesForCreating;
@property (nonatomic, retain) NSSet *availableTypesForChangingStatus;

@end
