//
//  AppDelegate.m
//  MSRequest
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

#import "AppDelegate.h"
#import "ReportsRootViewController.h"
#import <KinveyKit/KinveyKit.h>
#import "AuthenticationHelper.h"

@interface AppDelegate ()

@property (nonatomic, strong) ReportsRootViewController* rvc;
@property (nonatomic, strong) NSString* deepLink;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    //Kinvey: Setup configuration
	[KCSClient configureLoggingWithNetworkEnabled:YES
									 debugEnabled:YES
									 traceEnabled:YES
								   warningEnabled:YES
									 errorEnabled:YES];
#endif
    
    _rvc = (ReportsRootViewController*)[(UINavigationController*)self.window.rootViewController topViewController];

    return YES;
}

@end
