//
//  ActivityViewController.m
//  MSRequest
//
//  Created by Pavel Vilbik on 8.4.14.
//  Copyright (c) 2014 Intrepid Pursuits. All rights reserved.
//

#import "ActivityViewController.h"

#import "AuthenticationHelper.h"

@interface ActivityViewController ()

@end

@implementation ActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([AuthenticationHelper instance].isSignedIn) {
        
    }else{
        [self performSegueWithIdentifier:@"kSegueIdentifierModalSingInView" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
