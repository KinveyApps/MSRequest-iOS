//
//  MapAnnotation.m
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

#import "MapAnnotation.h"
#import "UIImage+Resize.h"
#import "DataHelper.h"

@implementation MapAnnotation
@synthesize subtitle=_subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)myCoord title:(NSString *)myTitle {
    self = [super init];
    if (self) {
        _coordinate = myCoord;
        _title = myTitle;
        [self setAddressFields:[[CLLocation alloc] initWithLatitude:myCoord.latitude longitude:myCoord.longitude]];
    }
    return self;
}

- (id)initWithReport:(Report *)report {
    self = [super init];
    if (self) {
        _reportModel = report;
        _coordinate = report.geoCoord.coordinate;
        _title = report.type.name;
        //identifier = aReport.identifier;
        // MB create image from imagePath
        //image = [aReport.image copy];
        [[DataHelper instance] loadImageByID:report.imageId
                                   OnSuccess:^(UIImage *image){
                                       
                                       UIImage *thumbnail = image;
                                       thumbnail = [thumbnail thumbnailImage:100 transparentBorder:0 cornerRadius:7 interpolationQuality:kCGInterpolationDefault];
                                       _image = thumbnail;
                                       
                                   }onFailure:nil];
         
        [self setAddressFields:[[CLLocation alloc] initWithLatitude:_coordinate.latitude longitude:_coordinate.longitude]];
    }
    return self;
}

- (NSString *) subtitle {
    if (_subtitle == nil) {
        return [NSString stringWithFormat:@"(%f , %f)",_coordinate.latitude,_coordinate.longitude];
    }
    return _subtitle;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

- (void)setAddressFields:(CLLocation *)loc {
    
    if (!self.reverseGeo) {
        self.reverseGeo = [[CLGeocoder alloc] init];
    }
    
    [self.reverseGeo reverseGeocodeLocation:loc
                          completionHandler:^(NSArray *placemarks, NSError *error) {
                              for (CLPlacemark *placemark in placemarks) {
                                  self.streetNumber = placemark.subThoroughfare;
                                  self.streetName = placemark.thoroughfare;
                                  self.city = placemark.locality;
                                  
                                  
                                  
                                  NSMutableString *locationString = [NSMutableString string];
                                  if (self.streetNumber) {
                                      [locationString appendString:self.streetNumber];
                                  }
                                  if (self.streetName) {
                                      [locationString appendString:self.streetName];
                                  }
                                  if (self.city) {
                                      [locationString appendString:self.city];
                                  }
                                  
                                  _subtitle = locationString;
                              }
                              [_delegate mapAnnotationFinishedReverseGeocoding:self];
                          }
     ];
}

@end
