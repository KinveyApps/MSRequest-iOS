//
//  MapAnnotation.m
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

#import "MapAnnotation.h"
#import "UIImage+Resize.h"
#import "DataHelper.h"

@implementation MapAnnotation

@synthesize subtitle=_subtitle;


#pragma mark - Initialization

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


#pragma mark - Setters and Getters

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
