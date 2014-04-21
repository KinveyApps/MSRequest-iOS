//
//  ImageScrollViewController.m
//  CityWatch
//
//  Copyright 2012 Intrepid Pursuits & Kinvey, Inc
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ImageScrollViewController.h"
#import "DataHelper.h"

@interface ImageScrollViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ImageScrollViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {

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
                               }onFailure:nil];
    
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
    doubleTap.numberOfTapsRequired = 2;
    [_mainScrollView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [tap requireGestureRecognizerToFail:doubleTap];
    [_mainScrollView addGestureRecognizer:tap];
}

- (void)viewDidUnload
{
    [self setMainScrollView:nil];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (CGRect)zoomRectForScale:(float)scale atCenter:(CGPoint)center {
    CGRect baseRect = _mainScrollView.frame;
    baseRect.size.width /= scale;
    baseRect.size.height /= scale;
    baseRect.origin.x = center.x - baseRect.size.width/2;
    baseRect.origin.y = center.y - baseRect.size.height/2;
    return baseRect;
}

#pragma mark - gesture handlers

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}

@end
