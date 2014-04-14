//
//  TextFieldTableViewCell.h
//  MSRequest
//
//  Created by Pavel Vilbik on 11.4.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextFieldTableViewCell;

@protocol TextFieldTableViewCellDelegate <NSObject>

- (void)textFieldTableViewCellDidBeginEditing:(TextFieldTableViewCell *)sender;
- (void)textFieldTableViewCellDidEndEditing:(TextFieldTableViewCell *)sender;

@end

@interface TextFieldTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) id<TextFieldTableViewCellDelegate> delegate;

@end
