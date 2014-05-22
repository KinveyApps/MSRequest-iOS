//
//  AppDelegate.m
//  MSRequest
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
    
    //Start push service
    [KCSPush registerForPush];
    
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
