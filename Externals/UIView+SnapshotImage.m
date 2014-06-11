//
//  UIView+SnapshotImage.m
//  MSRequest
//
//  Created by Pavel Vilbik on 10.6.14.
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

#import "UIView+SnapshotImage.h"

@implementation UIView (SnapshotImage)

// Return a snapshot image of this view
- (UIImage*)snapshot{
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIView *view = self;
    if (self.superview) {
        view = self.superview;
    }
    
    [view.layer renderInContext:context];
    
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return capturedImage;
}

@end
