//
//  TypeReport.h
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
