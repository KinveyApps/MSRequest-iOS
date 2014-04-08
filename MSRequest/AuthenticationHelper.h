//
//  SideMenuViewController.h
//  ContentBox
//
//  Created by Igor Sapyanik on 14.01.14.
//  Copyright (c) 2014 Igor Sapyanik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>

/*
#define KINVEY_APP_KEY				@"kid_eVmOXYVcbJ"
#define KINVEY_APP_SECRET			@"c9fdbd42a2d242619509b89960f4c49e"
*/

#define KINVEY_APP_KEY				@"kid_TVoDehwwo9"
#define KINVEY_APP_SECRET			@"93ee4b80d6024bffa4dc901dd6ef127f"




@interface AuthenticationHelper : NSObject

+ (AuthenticationHelper *)instance;

@property (nonatomic, readonly) BOOL isSignedIn;

- (void)signUpWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void (^)())successBlock onFailure:(void (^)(NSError *))failureBlock;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void (^)())successBlock onFailure:(void (^)(NSError *))failureBlock;
- (void)logout;
@end
