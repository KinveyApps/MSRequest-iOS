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

    [self startListening];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    //Kinvey: Rigstration on push service
    [[KCSPush sharedPush] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken completionBlock:^(BOOL success, NSError *error) {
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    //Kinvey: Get remote notification
    [[KCSPush sharedPush] application:application didReceiveRemoteNotification:userInfo];
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    //Kinvey: Fail to register for remote notification
    [[KCSPush sharedPush] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    
    //Kinvey: register for remote notification
    [[KCSPush sharedPush] registerForRemoteNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application{
    
    //Kinvey: Clean-up Push Service
    [[KCSPush sharedPush] onUnloadHelper];
}

- (void)startListening{
    
    //Kinvey: Listen notification about kinvey network activity
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(show)
                                                 name:KCSNetworkConnectionDidStart
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hide)
                                                 name:KCSNetworkConnectionDidEnd
                                               object:nil];
}

- (void) show{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void) hide{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
