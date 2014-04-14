//
//  TypeReport.h
//  MSRequest
//
//  Created by Pavel Vilbik on 9.4.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TYPES_OF_REPORT_KINVEY_COLLECTIONS_NAME @"TypesOfReport"

@interface TypeOfReport : NSObject <KCSPersistable>

@property (nonatomic, copy) NSString *entityId;         //Kinvey entity _id
@property (nonatomic, retain) KCSMetadata *metadata;    //Kinvey metadata

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSArray *reportState;
@property (nonatomic, retain) NSArray *additionalAttributes;
@property (nonatomic, retain) NSArray *additionalAttributesValidValues;

@end
