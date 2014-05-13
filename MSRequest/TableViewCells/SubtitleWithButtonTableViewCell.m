//
//  SubtitleWithButtonTableViewCell.m
//  MSRequest
//
//  Created by Pavel Vilbik on 12.5.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

#import "SubtitleWithButtonTableViewCell.h"

@implementation SubtitleWithButtonTableViewCell

- (IBAction)rigthButtonPress:(UIButton *)sender {
    
    [self.delegate rigthButtonPress:self];
}

@end
