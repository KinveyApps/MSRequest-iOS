//
//  ImageScrollViewController.m
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

#import "ImageScrollViewController.h"
#import "DataHelper.h"

@interface ImageScrollViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ImageScrollViewController


#pragma mark - View Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _mainScrollView.maximumZoomScale = 1.0;
	_mainScrollView.minimumZoomScale = 0.1;
	_mainScrollView.clipsToBounds = YES;
	_mainScrollView.delegate = self;
    
    [self.spinner startAnimating];
    
    //Load image by id
    [[DataHelper instance] loadImageByID:self.kinveyImageId
                               OnSuccess:^(UIImage *image){
                                   
                                   [self.spinner stopAnimating];
                                   
                                   self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
                                   _mainScrollView.contentSize = image.size;
                                   self.imageView.image = image;
                                   self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                                   float aspectHeight = self.mainScrollView.bounds.size.height / self.imageView.image.size.height;
                                   float aspectWidth = self.mainScrollView.bounds.size.width / self.imageView.image.size.width;
                                   self.mainScrollView.minimumZoomScale = MIN(aspectHeight, aspectWidth);
                                   
                                   [_mainScrollView setZoomScale:MAX(aspectHeight, aspectWidth)
                                                        animated:YES];
                                   [_mainScrollView addSubview:self.imageView];
                                   
                               }onFailure:^(NSError *error){
                                   
                                   [self.spinner stopAnimating];
                                   
                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                       message:error.localizedDescription
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"Cancel"
                                                                             otherButtonTitles:nil];
                                   [alertView show];
                               }];
    
    
    //Add double tap gesture for srollView
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
    doubleTap.numberOfTapsRequired = 2;
    [_mainScrollView addGestureRecognizer:doubleTap];
    
    //Add single tap gesture for scrollView
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [tap requireGestureRecognizerToFail:doubleTap];
    [_mainScrollView addGestureRecognizer:tap];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}


#pragma mark - Sroll View Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}


#pragma mark - Gesture Handlers

- (void)doubleTapGestureHandler:(UITapGestureRecognizer *)recognizer {
    // tap to zoom
    float scale = _mainScrollView.zoomScale;
    
    if (scale > _mainScrollView.minimumZoomScale) {
        [_mainScrollView setZoomScale:_mainScrollView.minimumZoomScale animated:YES];        
    }
    else {
        [_mainScrollView zoomToRect:[self zoomRectForScale:_mainScrollView.maximumZoomScale atCenter:[recognizer locationInView:_mainScrollView]] animated:YES];
    }
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)recognizer {
    
    BOOL navBarHidden = self.navigationController.navigationBarHidden;
    // if nav bar is hidden, unhide it before animation, since alpha is already 0
    if (navBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}


#pragma mark - Utils

- (CGRect)zoomRectForScale:(float)scale atCenter:(CGPoint)center {
    CGRect baseRect = _mainScrollView.frame;
    baseRect.size.width /= scale;
    baseRect.size.height /= scale;
    baseRect.origin.x = center.x - baseRect.size.width/2;
    baseRect.origin.y = center.y - baseRect.size.height/2;
    return baseRect;
}


@end
