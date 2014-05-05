//
//  DataHelper.h
//  MSRequest
//
//  Created by Pavel Vilbik on 15.4.14.
/**
 * Copyright (c) 2014, Kinvey, Inc. All rights reserved. *
 * This software is licensed to you under the Kinvey terms of service located at
 * http://www.kinvey.com/terms-of-use. By downloading, accessing and/or using this
 * software, you hereby accept such terms of service (and any agreement referenced
 * therein) and agree that you have read, understand and agree to be bound by such
 * terms of service and are of legal age to agree to such terms with Kinvey. *
 * This software contains valuable confidential and proprietary information of
 * KINVEY, INC and is subject to applicable licensing agreements.
 * Unauthorized reproduction, transmission or distribution of this file and its
 * contents is a violation of applicable laws. *
 */

#import <Foundation/Foundation.h>
#import "TypeOfReport.h"
#import "Report.h"

#define TYPE_FILTER_KEY             @"type"
#define STATE_FILTER_KEY            @"state"
#define LOCATION_RADIUS_FILTER_KEY  @"geoCoord"
#define DESCRIPTION_FILTER_KEY      @"descriptionOfReport"
#define ORIGINATOR_FILTER_KEY       @"originator"

//Define date format
#define FORMAT_DATE                             @"dd/MM/yyyy"


@interface DataHelper : NSObject

+ (DataHelper *)instance;

@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSArray *typesOfReport;
@property (strong, nonatomic) NSDictionary *filterOptions;

- (void)loadTypesOfReportUseCache:(BOOL)useCache OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure;
//- (void)saveQuote:(Quote *)quote OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(STErrorBlock)reportFailure;

- (void)loadReportUseCache:(BOOL)useCache withQuery:(KCSQuery *)query OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure;
- (void)saveReport:(Report *)report OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure;

- (void)loadImageByID:(NSString *)imageID OnSuccess:(void (^)(UIImage *))reportSuccess onFailure:(void(^)(NSError *))reportFailure;
- (void)saveImage:(UIImage *)image OnSuccess:(void (^)(NSString *))reportSuccess onFailure:(void(^)(NSError *))reportFailure;

- (NSArray *)mainFilterKey;

//- (void)loadProductsUseCache:(BOOL)useCache containtSubstinrg:(NSString *)substring OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(STErrorBlock)reportFailure;
//
//- (void)saveUserWithInfo:(NSDictionary *)userInfo OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(STErrorBlock)reportFailure;
//- (void)loadUserOnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(STErrorBlock)reportFailure;

@end
