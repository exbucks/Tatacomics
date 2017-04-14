//
//  LoginViewController.m
//  TataComics
//
//  Created by Albert on 1/20/15.
//  Copyright (c) 2015 Tataland. All rights reserved.
//

#import "LoginViewController.h"
#import "AppSettings.h"
#import "Common.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didSelectCountry:(NSDictionary *)country {
    [self.btnCountry setTitle:[NSString stringWithFormat:@"%@ >", [country objectForKey:@"name"]] forState:UIControlStateNormal];
    self.txtCallingCode.text = [NSString stringWithFormat:@"+%@", [country objectForKey:@"callingcode"]];
}

- (IBAction)callingCodeChanged:(id)sender {
    NSString* callingCode = self.txtCallingCode.text;
    
    if ([callingCode hasPrefix:@"+"])
        callingCode = [callingCode substringFromIndex:1];
    else
        self.txtCallingCode.text = [NSString stringWithFormat:@"+%@", callingCode];
    
    NSDictionary* country = [CountryViewController countryFromCallingCode:callingCode];
    NSString* countryName;
    if (country != nil)
        countryName = [country objectForKey:@"name"];
    else
        countryName = NSLocalizedString(@"Region", nil);
    
    [self.btnCountry setTitle:[NSString stringWithFormat:@"%@ >", countryName] forState:UIControlStateNormal];
}

- (IBAction)loginClicked:(id)sender {
    if (![self checkInputFields])
        return;
    
    NSString* callingCode = self.txtCallingCode.text;
    if ([callingCode hasPrefix:@"+"])
        callingCode = [callingCode substringFromIndex:1];
    NSString* phonenumber = [NSString stringWithFormat:@"%@%@", callingCode, self.txtPhoneNumber.text];
    NSString* password = self.txtPassword.text;

    // waiting message
    [Common showWaitingViewWithMessage:NSLocalizedString(@"Waiting", @"") container:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"%@/api/login", SERVER_URL];
    NSDictionary *parameters = @{ @"username" : phonenumber, @"password" : password };
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        // close waiting message
        [Common removeWaitingViewFromContainer:self.view];
        
        // check the result
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"Success"]) {

            // save user id
            [AppSettings sharedInstance].userID = phonenumber;
            
            // show library page
            UINavigationController* libraryNC  = [self.storyboard instantiateViewControllerWithIdentifier:@"libraryNavController"];
            [self.navigationController presentViewController:libraryNC animated:YES completion:nil];

        } else if ([[responseObject objectForKey:@"status"] isEqualToString:@"Failed"]) {
            
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                             message:NSLocalizedString([responseObject objectForKey:@"detail"], @"")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                   otherButtonTitles: nil];
            [alert show];
        } else {
            
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                             message:NSLocalizedString(@"ConnectionError", @"")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                   otherButtonTitles: nil];
            [alert show];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // close waiting message
        [Common removeWaitingViewFromContainer:self.view];

        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                         message:NSLocalizedString(@"ConnectionError", @"")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles: nil];
        [alert show];
    }];
}

- (BOOL)checkInputFields {
    NSString* callingCode = self.txtCallingCode.text;
    if ([callingCode hasPrefix:@"+"])
        callingCode = [callingCode substringFromIndex:1];
    
    if (callingCode.length == 0) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                         message:NSLocalizedString(@"CallingCodeEmpty", @"")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles: nil];
        [alert show];
        [self.txtCallingCode becomeFirstResponder];
        return NO;
    }
    
    if (self.txtPhoneNumber.text.length == 0) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                         message:NSLocalizedString(@"PhoneNumberEmpty", @"")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles: nil];
        [alert show];
        [self.txtPhoneNumber becomeFirstResponder];
        return NO;
    }
    
    if (self.txtPassword.text.length == 0) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                         message:NSLocalizedString(@"PasswordEmpty", @"")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles: nil];
        [alert show];
        [self.txtPassword becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;

    if (textField == self.txtCallingCode) {
        
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"+1234567890"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return ([string isEqualToString:filtered] && newLength <= 8);
        
    } else if (textField == self.txtPhoneNumber) {
        
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return ([string isEqualToString:filtered] && newLength <= 30);
        
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.txtCallingCode) {
        [textField resignFirstResponder];
        [self.txtPhoneNumber becomeFirstResponder];

    } else if (textField == self.txtPhoneNumber) {
        [textField resignFirstResponder];
        [self.txtPassword becomeFirstResponder];
    
    } else if (textField == self.txtPassword) {
        [self loginClicked:textField];
    }
    
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showRegister"]) {
        self.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Cancel", nil);
        
    } else if ([segue.identifier isEqualToString:@"showCountry"]) {
        self.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Back", nil);
        ((CountryViewController*)segue.destinationViewController).delegate = self;
        
    } else {
        self.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Back", nil);
    }
}

@end
