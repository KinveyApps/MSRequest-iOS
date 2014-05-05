//
//  AuthenticationHelper.h
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
#import <KinveyKit/KinveyKit.h>

#define KINVEY_APP_KEY				@"kid_TVoDehwwo9"
#define KINVEY_APP_SECRET			@"93ee4b80d6024bffa4dc901dd6ef127f"




@interface AuthenticationHelper : NSObject

+ (AuthenticationHelper *)instance;

@property (nonatomic, readonly) BOOL isSignedIn;

- (void)signUpWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void (^)())successBlock onFailure:(void (^)(NSError *))failureBlock;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void (^)())successBlock onFailure:(void (^)(NSError *))failureBlock;
- (void)logout;
@end
