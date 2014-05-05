//
//  MapAnnotation.h
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
#import <MapKit/MapKit.h>
#import "Report.h"

@protocol MapAnnotationDelegate;

@interface MapAnnotation : NSObject <MKAnnotation>

@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic) NSInteger identifier;
@property (strong, nonatomic) CLGeocoder *reverseGeo;
@property (strong, nonatomic) NSString *streetNumber;
@property (strong, nonatomic) NSString *streetName;
@property (strong, nonatomic) NSString *city;
@property (weak, nonatomic) id <MapAnnotationDelegate> delegate;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) Report *reportModel;

- (id)initWithCoordinate:(CLLocationCoordinate2D)myCoord title:(NSString *)myTitle;
- (id)initWithReport:(Report *)aReport;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate NS_AVAILABLE(NA, 4_0);
- (void)setAddressFields:(CLLocation *)loc;

@end

@protocol MapAnnotationDelegate

- (void)mapAnnotationFinishedReverseGeocoding:(MapAnnotation *)annotation;

@end
