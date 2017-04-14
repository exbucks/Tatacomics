//
//  RegisterViewController.h
//  TataComics
//
//  Created by Albert on 1/20/15.
//  Copyright (c) 2015 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryViewController.h"
#import "InsetTextField.h"

@interface RegisterViewController : UIViewController <CountryViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnCountry;
@property (weak, nonatomic) IBOutlet UITextField *txtCallingCode;
@property (weak, nonatomic) IBOutlet InsetTextField *txtPhoneNumber;
@property (weak, nonatomic) IBOutlet InsetTextField *txtPassword;
@property (weak, nonatomic) IBOutlet InsetTextField *txtConfirmPassword;

- (IBAction)callingCodeChanged:(id)sender;

- (IBAction)registerClicked:(id)sender;

@end
