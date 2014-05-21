//
//  EditHomeSreenTableViewController.h
//  MSRequest
//
//  Created by Pavel Vilbik on 12.5.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditHomeSreenTableViewController;

@protocol EditHomeSreenTableViewControllerDelegate <NSObject>

- (void)savePress:(EditHomeSreenTableViewController *)sender;

@end

@interface EditHomeSreenTableViewController : UITableViewController

@property (nonatomic, weak) id<EditHomeSreenTableViewControllerDelegate> delegate;

@end
