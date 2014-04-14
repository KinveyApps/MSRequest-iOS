//
//  TextFieldTableViewCell.m
//  MSRequest
//
//  Created by Pavel Vilbik on 11.4.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

#import "TextFieldTableViewCell.h"

@implementation TextFieldTableViewCell

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [self.delegate textFieldTableViewCellDidBeginEditing:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [self.delegate textFieldTableViewCellDidEndEditing:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
