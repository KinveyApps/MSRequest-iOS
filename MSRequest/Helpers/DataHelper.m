//
//  DataHelper.m
//  ContentBox
//
//  Created by Igor Sapyanik on 14.01.14.
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

@interface DataHelper ()

@property (nonatomic, strong) KCSLinkedAppdataStore *typesOfReportLinkedAppdataStore;
@property (nonatomic, strong) KCSLinkedAppdataStore *reportsLinkedAppdataStore;

@end

@implementation DataHelper

@synthesize formatter = _formatter;

SYNTHESIZE_SINGLETON_FOR_CLASS(DataHelper)


#pragma mark - Initialization

- (id)init {
    
	self = [super init];
    
	if (self) {
        
//        //Kinvey: Here we initialize KCSClient instance
//		(void)[[KCSClient sharedClient] initializeKinveyServiceForAppKey:KINVEY_APP_KEY
//														   withAppSecret:KINVEY_APP_SECRET
//															usingOptions:nil];
        
        //Kinvey: Here we define our collection to use
        KCSCollection *collectionTypesOfReport = [KCSCollection collectionFromString:TYPES_OF_REPORT_KINVEY_COLLECTIONS_NAME
                                                                             ofClass:[TypeOfReport class]];
        self.typesOfReportLinkedAppdataStore = [KCSLinkedAppdataStore storeWithOptions:@{ KCSStoreKeyResource       : collectionTypesOfReport,          //collection
                                                                                          KCSStoreKeyCachePolicy    : @(KCSCachePolicyNetworkFirst)}];  //default cache policy
        
        KCSCollection *collectionReports = [KCSCollection collectionFromString:REPORT_KINVEY_COLLECTIONS_NAME
                                                                       ofClass:[Report class]];
        self.reportsLinkedAppdataStore = [KCSLinkedAppdataStore storeWithOptions:@{ KCSStoreKeyResource       : collectionReports,              //collection
                                                                                    KCSStoreKeyCachePolicy    : @(KCSCachePolicyNetworkFirst)}];  //default cache policy

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


#pragma mark - Utils

- (NSString *)regexForContaintSubstring:(NSString *)substring{
    
    //Return string of regex format for search substring
    return [[@"^.{0,}" stringByAppendingString:substring] stringByAppendingString:@".{0,}"];
}

- (KCSQuery *)queryForOriginatorEqualsActiveUser{
    
    //Kinvey: Built a query for filter entity with field originator is equal avctive Kinvey user
    return [KCSQuery queryOnField:@"originator._id"
           withExactMatchForValue:[KCSUser activeUser].userId];
}

- (KCSQuery *)queryForSearchSubstring:(NSString *)substring inFields:(NSArray *)textFields{
    
    //Kinvey: Built complex query for filter entity which contains string field with substing
    KCSQuery *query = [KCSQuery query];
    
    query = [KCSQuery queryOnField:[textFields firstObject]
                         withRegex:[self regexForContaintSubstring:substring]];
    
    for (NSInteger i = 1; i < textFields.count; i ++) {
        KCSQuery *fieldQuery = [KCSQuery queryOnField:textFields[i]
                                            withRegex:[self regexForContaintSubstring:substring]];
        query = [query queryByJoiningQuery:fieldQuery
                             usingOperator:kKCSOr];
    }
    
    return query;
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
	[self.reportsLinkedAppdataStore queryWithQuery:(query ? query : [KCSQuery query])
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
    
    KCSMetadata *metadata = [[KCSMetadata alloc] init];
    [metadata setGloballyReadable:YES];
    [metadata setGloballyWritable:YES];
    
    [KCSFileStore uploadData:UIImagePNGRepresentation(image)
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

@end
