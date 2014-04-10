//
//  Report.h
//  MSRequest
//
//  Created by Pavel Vilbik on 10.4.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

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
@property (nonatomic, copy) NSString *descrition;

@end
