//
//  VerifyCodeViewController.h
//  TataComics
//
//  Created by Albert on 1/20/15.
//  Copyright (c) 2015 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsetTextField.h"


typedef NS_ENUM(NSInteger, VerificationType) {
    VerificationTypeRegister,
    VerificationTypeForgotPassword
};

@interface VerifyCodeViewController : UIViewController

@property (assign, nonatomic) VerificationType type;
@property (copy, nonatomic) NSString* userID;

@property (weak, nonatomic) IBOutlet InsetTextField *txtVerificationCode;

- (IBAction)submitClicked:(id)sender;

@end
