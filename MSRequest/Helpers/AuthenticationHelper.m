//
//  AuthenticationHelper.m
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

#import "AuthenticationHelper.h"
#import "SynthesizeSingleton.h"
#import "DataHelper.h"

@implementation AuthenticationHelper

SYNTHESIZE_SINGLETON_FOR_CLASS(AuthenticationHelper)

- (id)init {
	self = [super init];
	if (self) {
		(void)[[KCSClient sharedClient] initializeKinveyServiceForAppKey:KINVEY_APP_KEY
														   withAppSecret:KINVEY_APP_SECRET
															usingOptions:nil];

	}
	return self;
}

- (void)signUpWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void (^)())successBlock onFailure:(void (^)(NSError *))failureBlock {
	
	[KCSUser userWithUsername:username password:password fieldsAndValues:nil withCompletionBlock:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
		if (!errorOrNil) {
			if (successBlock) successBlock();
		}
		else {
			if (failureBlock) failureBlock(errorOrNil);
		}
	}];
}


- (void)loginWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void (^)())successBlock onFailure:(void (^)(NSError *))failureBlock {
	
	[KCSUser loginWithUsername:username password:password withCompletionBlock:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
		if (!errorOrNil) {
			if (successBlock) successBlock();
		}
		else {
			if (failureBlock) failureBlock(errorOrNil);
		}
    }];
}


- (BOOL)isSignedIn
{
    return [KCSUser activeUser] != nil;
}

- (void)logout
{
    [DataHelper instance].locationMaxDistanceFilter = 0;
    [DataHelper instance].filterOptions = nil;
	[[KCSUser activeUser] logout];
}

@end
