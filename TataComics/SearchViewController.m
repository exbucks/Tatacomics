//
//  SearchViewController.m
//  TataComics
//
//  Created by Albert Li on 11/15/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "SearchViewController.h"
#import "ThumbnailBookCell.h"
#import "BookInfoViewController.h"

#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "AppSettings.h"
#import "Common.h"
#import "IAPHelper.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // buttons
    [self.btnLibrary    setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"ButtonLibrary", nil)] forState:UIControlStateNormal];

    // page title
    [self.btnPageTitle setTitle:NSLocalizedString(@"Search", @"") forState:UIControlStateNormal];
    
    // keyword
    [self.txtSearch setText:self.keyword];
    
    // dismiss keyboard when touching outside of search box
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.booksCollectionView.collectionViewLayout;
    layout.itemSize = isPhone ? CGSizeMake(80, 130) : CGSizeMake(120, 195);

    [self updateShelfBackground];

    // data
    [self loadDataWithMessage:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // rounded page title
    self.btnPageTitle.layer.cornerRadius = self.btnPageTitle.frame.size.height / 2;
    
    // register keyboard event listener
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self updateShelfBackground];
//}
//
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    
//    [self updateShelfBackground];
//}

- (void)updateShelfBackground {
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.booksCollectionView.collectionViewLayout;
    CGSize rowSize = CGSizeMake(self.booksCollectionView.bounds.size.width, layout.itemSize.height);
    
    UIGraphicsBeginImageContext(rowSize);
    [[UIImage imageNamed:@"StoreShelfCommonCell"] drawInRect:CGRectMake(0, 0, rowSize.width, rowSize.height)];
    UIImage* rowImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.booksCollectionView.backgroundColor = [UIColor colorWithPatternImage:rowImage];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    CGRect kbFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGSize kbSize = [self.view convertRect:kbFrame fromView:self.view.window].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)dismissKeyboard {
    [self.txtSearch resignFirstResponder];
}

- (void)loadDataWithMessage:(BOOL)message {
    // waiting message
    if (message)
        [Common showWaitingViewWithMessage:NSLocalizedString(@"Waiting", @"") container:self.view];
    
    // search by keyword
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/search/%@", SERVER_URL, self.keyword]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // close waiting message
        if (message)
            [Common removeWaitingViewFromContainer:self.view];
        
        // save the result
        self.booksData = responseObject;

        // reload UI
        [self.booksCollectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // close waiting message
        if (message)
            [Common removeWaitingViewFromContainer:self.view];
    }];
    
    [operation start];
}

- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)libraryClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showInformationOfBook:(NSString*)bookId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/info/%@", SERVER_URL, bookId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // waiting message
    [Common showWaitingViewWithMessage:NSLocalizedString(@"Waiting", @"") container:self.view];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString* bundleId = [responseObject objectForKey:@"bundle"];
        double price = ((NSString*)[responseObject objectForKey:@"price"]).doubleValue;
        
        if (price == 0) {
            
            // close waiting message
            [Common removeWaitingViewFromContainer:self.view];
            
            // show info dialog
            BookInfoViewController* vc  = [self.storyboard instantiateViewControllerWithIdentifier:@"bookInfoViewController"];
            vc.data = responseObject;
            vc.skProduct = nil;
            [Common setPresentationStyleForSelfController:self presentingController:vc];
            [self presentViewController:vc animated:YES completion:nil];
            
        } else {
            // get IAP info such as price from App Store
            [[IAPHelper sharedInstance] requestProducts:[NSSet setWithObjects:bundleId, nil] completionHandler:^(BOOL success, NSArray *products) {
                
                // close waiting message
                [Common removeWaitingViewFromContainer:self.view];
                
                if (success && products.count > 0) {
                    // show info dialog
                    BookInfoViewController* vc  = [self.storyboard instantiateViewControllerWithIdentifier:@"bookInfoViewController"];
                    vc.data = responseObject;
                    vc.skProduct = [products objectAtIndex:0];
                    [Common setPresentationStyleForSelfController:self presentingController:vc];
                    [self presentViewController:vc animated:YES completion:nil];
                } else {
                    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"DearKids", @"")
                                                                     message:NSLocalizedString(@"BookIsPreparing", @"")
                                                                    delegate:nil
                                                           cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                                           otherButtonTitles: nil];
                    [alert show];
                }
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // close waiting message
        [Common removeWaitingViewFromContainer:self.view];
        
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                         message:NSLocalizedString(@"ConnectionError", @"")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                               otherButtonTitles: nil];
        [alert show];
    }];
    
    [operation start];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    if (textField == self.txtSearch) {
        // hide keyboard
        [textField resignFirstResponder];
        
        // reserach
        self.keyword = self.txtSearch.text;
        [self loadDataWithMessage:YES];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.booksData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // data for book
    NSDictionary* data = [self.booksData objectAtIndex:indexPath.item];
    
    // make the cell
    ThumbnailBookCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbnailBookCell" forIndexPath:indexPath];
    cell.lblTitle.text = [data objectForKey:@"title"];

    NSString *path = [data objectForKey:@"image"];
    [cell.imgCover setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"UnknownBookListImage"]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // data for book
    NSDictionary* data = [self.booksData objectAtIndex:indexPath.item];
    NSString *bookId = [data objectForKey:@"id"];
    
    // show info dialog
    [self showInformationOfBook:bookId];
}

@end
