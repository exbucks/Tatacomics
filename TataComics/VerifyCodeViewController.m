//
//  VerifyCodeViewController.m
//  TataComics
//
//  Created by Albert on 1/20/15.
//  Copyright (c) 2015 Tataland. All rights reserved.
//

#import "VerifyCodeViewController.h"
#import "AppSettings.h"
#import "Common.h"

@interface VerifyCodeViewController ()

@end

@implementation VerifyCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitClicked:(id)sender {
    if (self.txtVerificationCode.text.length == 0) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                         message:NSLocalizedString(@"VerificationCodeEmpty", @"")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles: nil];
        [alert show];
        [self.txtVerificationCode becomeFirstResponder];
        return;
    }
    
    switch (self.type) {
        case VerificationTypeRegister:
            [self finishRegister];
        case VerificationTypeForgotPassword:
            break;
    }
}

- (void)finishRegister {
    // waiting message
    [Common showWaitingViewWithMessage:NSLocalizedString(@"Waiting", @"") container:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"%@/api/register2", SERVER_URL];
    NSDictionary *parameters = @{ @"username" : self.userID, @"code" : self.txtVerificationCode.text };
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        // close waiting message
        [Common removeWaitingViewFromContainer:self.view];
        
        // check the result
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"Success"]) {

            // save user id
            [AppSettings sharedInstance].userID = self.userID;
            
            // next, show library page
            UINavigationController* libraryNC  = [self.storyboard instantiateViewControllerWithIdentifier:@"libraryNavController"];
            [self.navigationController presentViewController:libraryNC animated:YES completion:nil];
            
            // first, goto login page
            [self.navigationController popToRootViewControllerAnimated:NO];
            
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.txtVerificationCode) {
        [self submitClicked:textField];
    }
    
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
