//
//  RootCollectionViewCell.h
//  MSRequest
//
//  Created by Pavel Vilbik on 15.4.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KinveyImageView.h"

@interface RootCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet KinveyImageView *kinveyImageView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationsLabel;

@end
