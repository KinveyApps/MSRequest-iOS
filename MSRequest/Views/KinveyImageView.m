//
//  KinveyImageView.m
//
//  Created by Pavel Vilbik on 4.3.14.
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

#import "KinveyImageView.h"
#import "UIView+SnapshotImage.h"
#import "UIImage+AHKAdditions.h"

@interface KinveyImageView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end


@implementation KinveyImageView


#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    [[NSBundle mainBundle] loadNibNamed:@"KinveyImageView" owner:self options:nil];
    [self addSubview:self.view];
    self.view.frame = self.bounds;
}


#pragma mark - Setter

- (void)setKinveyID:(NSString *)kinveyID{
        
    if (kinveyID.length) {
        
        if (![_kinveyID isEqualToString:kinveyID]) {
            _kinveyID = kinveyID;
            [self.spinner startAnimating];
            
            self.imageView.image = nil;
            self.headerImageView.image = nil;
            
            //Kinvey: Laod image file
            [KCSFileStore downloadFile:kinveyID                         //File ID
                               options:@{KCSFileOnlyIfNewer : @(YES)}   //Get file from cache if can
                       completionBlock: ^(NSArray *downloadedResources, NSError *error) {
                           
                           if (error == nil) {
                               KCSFile* file = downloadedResources[0];
                               if ([self.kinveyID isEqualToString:file.fileId]) {
                                   NSURL* fileURL = file.localURL;
                                   UIImage* image = [UIImage imageWithContentsOfFile:[fileURL path]];
                                   
                                   
                                   //Return to main thread for update UI
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       self.imageView.image = image;
                                       UIImage *headerImage = [self.blurHeaderView snapshot];
                                       headerImage = [headerImage ahk_applyBlurWithRadius:10.0f
                                                                                tintColor:[UIColor colorWithWhite:1.0f alpha:0.5f] saturationDeltaFactor:1.8f maskImage:nil];
                                       self.headerImageView.image = headerImage;
                                       [self.spinner stopAnimating];
                                       [self.imageView setNeedsDisplay];
                                   });
                               }
                               
                           } else {
                               NSLog(@"Got an error: %@", error);
                           }
                       } progressBlock:nil];
        }
    }else{
        self.imageView.image = nil;
    }
}


#pragma mark - Utility

- (UIImage *)imageWithImage:(UIImage *)image size:(CGSize)size {
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
