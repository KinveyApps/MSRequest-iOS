//
//  DataHelper.m
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

#import "DataHelper.h"

#define FILTER_OPTIONS_USER_DEFAULTS_KEY @"FilterOptions"

@interface DataHelper ()

@property (nonatomic, strong) KCSLinkedAppdataStore *typesOfReportLinkedAppdataStore;
@property (nonatomic, strong) KCSLinkedAppdataStore *reportsLinkedAppdataStore;
@property (nonatomic, strong) KCSQuery *currentQuery;
@end

@implementation DataHelper

@synthesize formatter = _formatter;
@synthesize filterOptions = _filterOptions;

SYNTHESIZE_SINGLETON_FOR_CLASS(DataHelper)


#pragma mark - Initialization

- (id)init {
    
	self = [super init];
    
	if (self) {
        
        //Kinvey: Here we define our collection to use
        KCSCollection *collectionTypesOfReport = [KCSCollection collectionFromString:TYPES_OF_REPORT_KINVEY_COLLECTIONS_NAME
                                                                             ofClass:[TypeOfReport class]];
        self.typesOfReportLinkedAppdataStore = [KCSLinkedAppdataStore storeWithOptions:@{ KCSStoreKeyResource       : collectionTypesOfReport,          //collection
                                                                                          KCSStoreKeyCachePolicy    : @(KCSCachePolicyNetworkFirst)}];  //default cache policy
        
        KCSCollection *collectionReports = [KCSCollection collectionFromString:REPORT_KINVEY_COLLECTIONS_NAME
                                                                       ofClass:[Report class]];
        self.reportsLinkedAppdataStore = [KCSLinkedAppdataStore storeWithOptions:@{ KCSStoreKeyResource       : collectionReports,                  //collection
                                                                                    KCSStoreKeyCachePolicy    : @(KCSCachePolicyNetworkFirst)}];    //default cache policy

	}
    
    self.currentQuery = [KCSQuery query];
    
    NSArray *options = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_OPTIONS_USER_DEFAULTS_KEY];
    
    if (options){
        self.filterOptions = options;
    }
    
	return self;
}


#pragma mark - Setters and Getters

- (NSDateFormatter *)formatter{
    
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [_formatter setDateFormat:FORMAT_DATE];
    }
    
    return _formatter;
}

- (NSArray *)filterOptions{
    if (!_filterOptions){
        _filterOptions = [NSArray array];
    }
    return _filterOptions;
}

- (void)setFilterOptions:(NSArray *)filterOptions{
    
    self.currentQuery = nil;
    
    _filterOptions = filterOptions;
    
    self.currentQuery = [self getQueryFromFilterOptions:filterOptions];

    if (filterOptions.count){
        [[NSUserDefaults standardUserDefaults] setObject:filterOptions forKey:FILTER_OPTIONS_USER_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:FILTER_OPTIONS_USER_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setCurrentLocation:(CLLocation *)currentLocation{
    _currentLocation = currentLocation;
    
    if (currentLocation) {
        self.currentQuery = [self getQueryFromFilterOptions:self.filterOptions];
    }
}


#pragma mark - Utils

- (KCSQuery *)getQueryFromFilterOptions:(NSArray *)filterOptions{
    
    //Kinvey: create query with filter options
    KCSQuery *resultQuery = nil;
    TypeOfReport *currentType = nil;
    
    if (!self.typesOfReport.count) {
        return [KCSQuery query];
    }
    
    for (NSDictionary *filterType in filterOptions){
        
        KCSQuery *queryForCurrentType = [KCSQuery query];
        
        if (filterType[TYPE_FILTER_KEY]) {
            for (TypeOfReport *type in self.typesOfReport) {
                if ([type.entityId isEqualToString:filterType[TYPE_FILTER_KEY]]) {
                    currentType = type;
                    break;
                }
            }
            queryForCurrentType = [KCSQuery queryOnField:@"type._id"
                                  withExactMatchForValue:filterType[TYPE_FILTER_KEY]];
        }
        
        if (filterType[ORIGINATOR_FILTER_KEY]) {
            KCSQuery *originatorQuery = [KCSQuery queryOnField:@"originator._id"
                                        withExactMatchForValue:filterType[ORIGINATOR_FILTER_KEY]];
            queryForCurrentType = [queryForCurrentType queryByJoiningQuery:originatorQuery
                                                             usingOperator:kKCSAnd];
        }
        
        
        if (filterType[STATE_FILTER_KEY]) {
            KCSQuery *stateQuery = [KCSQuery queryOnField:@"state"
                                   withExactMatchForValue:filterType[STATE_FILTER_KEY]];
            queryForCurrentType = [KCSQuery queryForJoiningOperator:kKCSAnd
                                                          onQueries:stateQuery, queryForCurrentType, nil];
        }
        if (filterType[LOCATION_RADIUS_FILTER_KEY] && self.currentLocation) {

            NSNumber *longitude = [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude];
            NSNumber *latitude = [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude];
            NSNumber *distance = [NSNumber numberWithFloat:[(NSNumber *)filterType[LOCATION_RADIUS_FILTER_KEY] floatValue] * 0.00015719741];
            KCSQuery *geoQuery = [KCSQuery queryOnField:KCSEntityKeyGeolocation
                       usingConditionalsForValues:
                            kKCSNearSphere, @[longitude, latitude],
                            kKCSMaxDistance, distance, nil];
            queryForCurrentType = [KCSQuery queryForJoiningOperator:kKCSAnd
                                                          onQueries:geoQuery, queryForCurrentType, nil];
        }
        if (filterType[DESCRIPTION_FILTER_KEY]) {
            KCSQuery *decriptionQuery = [KCSQuery queryOnField:@"descriptionOfReport"
                                              withRegex:[self regexForContaintSubstring:filterType[DESCRIPTION_FILTER_KEY]]];
            queryForCurrentType = [KCSQuery queryForJoiningOperator:kKCSAnd
                                                          onQueries:decriptionQuery, queryForCurrentType, nil];
        }
        if (currentType) {
            for (NSInteger i = 0; i < currentType.additionalAttributes.count; i++) {
                NSString *attribute = currentType.additionalAttributes[i];
                if (filterType[attribute]) {
                    if ([currentType.additionalAttributesValidValues[i] isKindOfClass:[NSArray class]]) {
                        KCSQuery *query = [KCSQuery queryOnField:[NSString stringWithFormat:@"valuesAdditionalAttributes.%ld", (long)i]
                                                    withExactMatchForValue:filterType[attribute]];
                        queryForCurrentType = [KCSQuery queryForJoiningOperator:kKCSAnd
                                                                      onQueries:query, queryForCurrentType, nil];
                    }else{
                        KCSQuery *query = [KCSQuery queryOnField:[NSString stringWithFormat:@"valuesAdditionalAttributes.%ld", (long)i]
                                                       withRegex:[self regexForContaintSubstring:filterType[attribute]]];
                        queryForCurrentType = [KCSQuery queryForJoiningOperator:kKCSAnd
                                                                      onQueries:query, queryForCurrentType, nil];
                    }
                }
            }
        }
        if (resultQuery){
            resultQuery = [resultQuery queryByJoiningQuery:queryForCurrentType
                                             usingOperator:kKCSOr];
        }else{
            resultQuery = queryForCurrentType;
        }
    }
    
    return resultQuery ? resultQuery : [KCSQuery query];
}

- (NSString *)regexForContaintSubstring:(NSString *)substring{
    
    //Return string of regex format for search substring
    return [[@"^.{0,}" stringByAppendingString:substring] stringByAppendingString:@".{0,}"];
}


#pragma mark - Types of Report
#pragma mark - Load Entity

- (void)loadTypesOfReportUseCache:(BOOL)useCache OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure{

    KCSQuery *query = [KCSQuery query];
    
    //Kinvey: Load entity from Quote collection which correspond query
	[self.typesOfReportLinkedAppdataStore queryWithQuery:query
                                     withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                                         
                                         //Return to main thread for update UI
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (!errorOrNil) {
                                                 if (self.typesOfReport.count != objectsOrNil.count) {
                                                     self.typesOfReport = objectsOrNil;
                                                     self.currentQuery = [self getQueryFromFilterOptions:self.filterOptions];
                                                 }
                                                 if (reportSuccess) reportSuccess(objectsOrNil);
                                             }else{
                                                 if (reportFailure) reportFailure(errorOrNil);
                                             }
                                         });
                                         
                                     }
                                       withProgressBlock:nil
                                             cachePolicy:useCache ? KCSCachePolicyLocalFirst : KCSCachePolicyNetworkFirst];
    
}


#pragma mark - Reports
#pragma mark - Save and Load Entity

- (void)loadReportUseCache:(BOOL)useCache withQuery:(KCSQuery *)query OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure{
    
    //Kinvey: Load entity from Quote collection which correspond query
	[self.reportsLinkedAppdataStore queryWithQuery:(query ? query : self.currentQuery)
                               withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                                   
                                   //Return to main thread for update UI
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (!errorOrNil) {
                                           if (reportSuccess) reportSuccess(objectsOrNil);
                                       }else{
                                           if (reportFailure) reportFailure(errorOrNil);
                                       }
                                   });
                                   
                               }
                                 withProgressBlock:nil
                                       cachePolicy:useCache ? KCSCachePolicyLocalFirst : KCSCachePolicyNetworkFirst];
    
}

- (void)saveReport:(Report *)report OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure{

    //Kinvey: Save object to Quote collection
    [self.reportsLinkedAppdataStore saveObject:report
                           withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                               
                               //Return to main thread for update UI
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (errorOrNil != nil) {
                                       if (reportFailure) reportFailure(errorOrNil);
                                   } else {
                                       if (reportSuccess) reportSuccess(objectsOrNil);
                                   }
                               });
                               
                           }
                             withProgressBlock:nil];
}


#pragma mark - Image
#pragma mark - Save and Load Attributes

- (void)loadImageByID:(NSString *)imageID OnSuccess:(void (^)(UIImage *))reportSuccess onFailure:(void(^)(NSError *))reportFailure{
    
    //Kinvey: Laod image file
    [KCSFileStore downloadFile:imageID                          //File ID
                       options:@{KCSFileOnlyIfNewer : @(YES)}   //Get file from cache if can
               completionBlock: ^(NSArray *downloadedResources, NSError *error) {
                   
                   if (error == nil) {
                       KCSFile* file = downloadedResources[0];
                       NSURL* fileURL = file.localURL;
                       UIImage* image = [UIImage imageWithContentsOfFile:[fileURL path]];
                       
                       //Return to main thread for update UI
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if (reportSuccess) {
                               reportSuccess(image);
                           }
                       });
                       
                   } else {
                       //Return to main thread for update UI
                       dispatch_async(dispatch_get_main_queue(), ^{
                           NSLog(@"Got an error: %@", error);
                           if (reportFailure) {
                               reportFailure(error);
                           }
                       });
                   }
               } progressBlock:nil];
}

- (void)saveImage:(UIImage *)image OnSuccess:(void (^)(NSString *))reportSuccess onFailure:(void(^)(NSError *))reportFailure{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        KCSMetadata *metadata = [[KCSMetadata alloc] init];
        [metadata setGloballyReadable:YES];
        [metadata setGloballyWritable:YES];
        
        [KCSFileStore uploadData:UIImageJPEGRepresentation(image, 0.25)
                         options:@{KCSFileACL: metadata,
                                   KCSFilePublic :@(YES)}
                 completionBlock:^(KCSFile* uploadInfo, NSError* error){
                     
                     if (!error) {
                         NSString *fileID = uploadInfo.fileId;
                         
                         //Return to main thread for update UI
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (reportSuccess) {
                                 reportSuccess(fileID);
                             }
                         });
                     }else{
                         
                         //Return to main thread for update UI
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (reportFailure) {
                                 reportFailure(error);
                             }
                         });
                     }
                 }progressBlock:nil];
    });
}


#pragma mark - USER
#pragma mark - Save and Load Attributes

- (void)saveUserWithInfo:(NSDictionary *)userInfo OnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure{
    
    //Kinvey: Get current active user
    KCSUser *user = [KCSUser activeUser];
    
    if (user) {
        NSArray *keyArray = [self allUserInfoKey];
        
        //Kinvey: Add current user attribute from user info
        for (int i = 0; i < keyArray.count; i++) {
            if (userInfo[keyArray[i]]) {
                [user setValue:userInfo[keyArray[i]]
                  forAttribute:keyArray[i]];
            }
        }
        
        //Kinver: Save current active user data
        [user saveWithCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
            
            //Return to main thread for update UI
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!errorOrNil) {
                    if (reportSuccess) reportSuccess(objectsOrNil);
                }
                else {
                    if (reportFailure) reportFailure(errorOrNil);
                }
            });
            
        }];
    }
}

- (void)loadUserOnSuccess:(void (^)(NSArray *))reportSuccess onFailure:(void (^)(NSError *))reportFailure{
    
    //Kinvey: Get current active user
    KCSUser *user = [KCSUser activeUser];
    
    //Kinvey: Update data of current active user
    [user refreshFromServer:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        
        //Return to main thread for update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!errorOrNil) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                NSArray *keyArray = [self allUserInfoKey];
                
                //Kinvey: extract user data to dictionary
                for (int i = 0; i < keyArray.count; i++) {
                    if ([user getValueForAttribute:keyArray[i]]) {
                        userInfo[keyArray[i]] = [user getValueForAttribute:keyArray[i]];
                    }
                }
                
                if (reportSuccess) reportSuccess(@[[userInfo copy]]);
            }
            else {
                if (reportFailure) reportFailure(errorOrNil);
            }
        });
        
    }];
}

#pragma mark - Utils

- (NSArray *)allUserInfoKey{
    
    //Return attribute user key which use in app
    return @[REPORT_TYPE_IDS_FOR_NOTIFICATION];
    
}

- (NSArray *)mainFilterKey{
    return @[ORIGINATOR_FILTER_KEY,
             TYPE_FILTER_KEY,
             STATE_FILTER_KEY,
             LOCATION_RADIUS_FILTER_KEY,
             DESCRIPTION_FILTER_KEY];
}

@end
