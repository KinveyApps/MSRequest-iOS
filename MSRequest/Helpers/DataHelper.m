//
//  DataHelper.m
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

#import "DataHelper.h"

@interface DataHelper ()

@property (nonatomic, strong) KCSLinkedAppdataStore *typesOfReportLinkedAppdataStore;
@property (nonatomic, strong) KCSLinkedAppdataStore *reportsLinkedAppdataStore;
@property (nonatomic, strong) KCSQuery *currentQuery;
@end

@implementation DataHelper

@synthesize formatter = _formatter;

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

- (void)setFilterOptions:(NSDictionary *)filterOptions{
    
    self.currentQuery = [KCSQuery query];
    TypeOfReport *currentType;
    
    _filterOptions = filterOptions;
    
    //Kinvey: create query with filter options
    if (filterOptions[ORIGINATOR_FILTER_KEY]) {
        [self.currentQuery addQueryForJoiningOperator:kKCSAnd
                                            onQueries:[KCSQuery queryOnField:@"originator._id"
                                                      withExactMatchForValue:filterOptions[ORIGINATOR_FILTER_KEY]], nil];
    }
    if (filterOptions[TYPE_FILTER_KEY]) {
        for (TypeOfReport *type in self.typesOfReport) {
            if ([type.entityId isEqualToString:filterOptions[TYPE_FILTER_KEY]]) {
                currentType = type;
                break;
            }
        }
        [self.currentQuery addQueryForJoiningOperator:kKCSAnd
                                            onQueries:[KCSQuery queryOnField:@"type._id"
                                                      withExactMatchForValue:filterOptions[TYPE_FILTER_KEY]], nil];
    }
    if (filterOptions[STATE_FILTER_KEY]) {
        [self.currentQuery addQueryForJoiningOperator:kKCSAnd
                                            onQueries:[KCSQuery queryOnField:@"state"
                                                      withExactMatchForValue:filterOptions[STATE_FILTER_KEY]], nil];
    }
    if (filterOptions[LOCATION_RADIUS_FILTER_KEY]) {
        [self.currentQuery addQueryForJoiningOperator:kKCSAnd
                                            onQueries:[KCSQuery queryOnField:KCSEntityKeyGeolocation
                                                  usingConditionalsForValues:kKCSMaxDistance, filterOptions[LOCATION_RADIUS_FILTER_KEY], nil], nil];
    }
    if (filterOptions[DESCRIPTION_FILTER_KEY]) {
        [self.currentQuery addQueryForJoiningOperator:kKCSAnd
                                            onQueries:[KCSQuery queryOnField:@"descriptionOfReport"
                                                                   withRegex:[self regexForContaintSubstring:filterOptions[DESCRIPTION_FILTER_KEY]]], nil];
    }
    if (currentType) {
        for (NSInteger i = 0; i < currentType.additionalAttributes.count; i++) {
            NSString *attribute = currentType.additionalAttributes[i];
            if (filterOptions[attribute]) {
                if ([currentType.additionalAttributesValidValues[i] isKindOfClass:[NSArray class]]) {
                    [self.currentQuery addQueryForJoiningOperator:kKCSAnd
                                                        onQueries:[KCSQuery queryOnField:[NSString stringWithFormat:@"valuesAdditionalAttributes.%d", i]
                                                                  withExactMatchForValue:filterOptions[attribute]], nil];
                }else{
                    [self.currentQuery addQueryForJoiningOperator:kKCSAnd
                                                        onQueries:[KCSQuery queryOnField:[NSString stringWithFormat:@"valuesAdditionalAttributes.%d", i]
                                                                               withRegex:[self regexForContaintSubstring:filterOptions[attribute]]], nil];
                }
            }
        }
    }
}


#pragma mark - Utils

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
                                                 self.typesOfReport = objectsOrNil;
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
    
//    //Return attribute user key which use in app
//    return @[USER_INFO_KEY_CONTACT,
//             USER_INFO_KEY_COMPANY,
//             USER_INFO_KEY_ACCOUNT_NUMBER,
//             USER_INFO_KEY_PHONE,
//             USER_INFO_KEY_PUSH_NOTIFICATION_ENABLE,
//             USER_INFO_KEY_EMAIL_CONFIRMATION_ENABLE,
//             USER_INFO_KEY_EMAIL];
    return @[];
}

- (NSArray *)mainFilterKey{
    return @[ORIGINATOR_FILTER_KEY,
             TYPE_FILTER_KEY,
             STATE_FILTER_KEY,
             LOCATION_RADIUS_FILTER_KEY,
             DESCRIPTION_FILTER_KEY];
}

@end
