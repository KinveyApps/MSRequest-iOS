//
//  DataHelper.h
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
#import "TypeOfReport.h"
#import "Report.h"
#import "UserRoles.h"

//Main Filter Options Key
#define TYPE_FILTER_KEY                 @"type"
#define STATE_FILTER_KEY                @"state"
#define LOCATION_RADIUS_FILTER_KEY      @"geoCoord"
#define DESCRIPTION_FILTER_KEY          @"descriptionOfReport"
#define ORIGINATOR_FILTER_KEY           @"originator"

//User Info User Key
#define REPORT_TYPE_IDS_FOR_NOTIFICATION    @"ArrayIDforPushNotification"
#define ID_USER_ROLE                        @"UserRoleID"

//Define date format
#define FORMAT_DATE                             @"dd/MM/yyyy"


@interface DataHelper : NSObject

+ (DataHelper *)instance;

@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSArray *typesOfReport;
@property (strong, nonatomic) NSArray *filterOptions;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) CGFloat locationMaxDistanceFilter;
@property (nonatomic, strong) UserRoles *currentUserRole;

- (void)loadTypesOfReportUseCache:(BOOL)useCache OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure;
- (void)loadUserRolesUseCache:(BOOL)useCache OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure;

- (void)loadReportUseCache:(BOOL)useCache withQuery:(KCSQuery *)query OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure;
- (void)saveReport:(Report *)report OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure;

- (void)loadImageByID:(NSString *)imageID OnSuccess:(void (^)(UIImage *))reportSuccess onFailure:(void(^)(NSError *))reportFailure;
- (void)saveImage:(UIImage *)image OnSuccess:(void (^)(NSString *))reportSuccess onFailure:(void(^)(NSError *))reportFailure;

- (void)saveUserWithInfo:(NSDictionary *)userInfo OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure;
- (void)loadUserOnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure;
- (void)updateUserRole:(NSString *)roleID OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure;

- (NSArray *)mainFilterKey;

@end
