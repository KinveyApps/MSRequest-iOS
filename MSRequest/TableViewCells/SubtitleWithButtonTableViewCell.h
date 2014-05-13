//
//  SubtitleWithButtonTableViewCell.h
//  MSRequest
//
//  Created by Pavel Vilbik on 12.5.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubtitleWithButtonTableViewCell;

@protocol SubtitleWithButtonTableViewCellDelegate

- (void)rigthButtonPress:(SubtitleWithButtonTableViewCell *)sender;

@end

@interface SubtitleWithButtonTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UIButton *rigthButton;

@property (weak, nonatomic) id<SubtitleWithButtonTableViewCellDelegate> delegate;

@end
