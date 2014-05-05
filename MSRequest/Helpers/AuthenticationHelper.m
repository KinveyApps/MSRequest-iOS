//
//  AuthenticationHelper.m
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

#import "AuthenticationHelper.h"
#import "SynthesizeSingleton.h"

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
	[[KCSUser activeUser] logout];
}

@end
