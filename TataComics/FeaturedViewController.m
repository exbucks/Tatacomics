//
//  FeaturedViewController.m
//  TataComics
//
//  Created by Albert Li on 11/15/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "FeaturedViewController.h"
#import "FeaturedBannerRow.h"
#import "ThumbnailBookCell.h"
#import "BookInfoViewController.h"
#import "CategorizedViewController.h"
#import "SpecificViewController.h"
#import "SearchViewController.h"

#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "AppSettings.h"
#import "Common.h"
#import "IAPHelper.h"
#import "ActionSheetPicker.h"

#define BANNER_VIEW_ITEM_RATIO              1.932
#define BANNER_ITEM_WIDTH_HEIGHT_RATIO      2

@interface FeaturedViewController () {
    iCarousel* bannerView;
    FeaturedBannerRow* bannerContainerRow;
    NSTimer* bannerTimer;
    
    UIDocumentInteractionController* docController;
    
    BOOL loading;
}

@end

@implementation FeaturedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    loading = NO;
    transitionCount = 0;
    
    // buttons
    [self.btnCategory   setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"ButtonCategory", nil)] forState:UIControlStateNormal];
    [self.btnLibrary    setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"ButtonLibrary", nil)] forState:UIControlStateNormal];
    [self.btnPurchased  setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"ButtonPurchased", nil)] forState:UIControlStateNormal];
    [self.btnShare      setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"ButtonShare", nil)] forState:UIControlStateNormal];

    // page title
    self.btnPageTitle.hidden = YES;
    [self.btnPageTitle setTitle:NSLocalizedString(@"Featured", @"") forState:UIControlStateNormal];
    
    // banner
    bannerContainerRow = [[FeaturedBannerRow alloc] init];
    
    bannerView = [[iCarousel alloc] initWithFrame:CGRectZero];
    bannerView.type = iCarouselTypeCoverFlow;
    bannerView.delegate = self;
    bannerView.dataSource = self;
    bannerView.decelerationRate = 0.5;
    [bannerContainerRow.contentView addSubview:bannerView];

    [bannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [bannerContainerRow.contentView addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"H:|-0-[bannerView]-0-|"
                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                         metrics:nil
                                         views:NSDictionaryOfVariableBindings(bannerView)]];
    [bannerContainerRow.contentView addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"V:|-0-[bannerView]-0-|"
                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                         metrics:nil
                                         views:NSDictionaryOfVariableBindings(bannerView)]];
    
    bannerTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(stepBanner) userInfo:nil repeats:YES];
    
    // dismiss keyboard when touching outside of search box
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    
    int bannerWidth, bannerHeight, bw, bh;
    float rate;
    bannerWidth = [UIScreen mainScreen].bounds.size.width;
    bannerHeight = [UIScreen mainScreen].bounds.size.height;
    if (bannerWidth > 1000 || bannerHeight > 1000) {
        rate = 1;
    } else {
        rate = 1.5;
    }

    bannerWidth = bannerWidth*0.83; bannerHeight = bannerHeight*0.57;
    bw = bannerWidth / rate; bh = bw / BANNER_ITEM_WIDTH_HEIGHT_RATIO;
    
    bannerContainerRow.backgroundColor = [UIColor clearColor];
    
    CGRect featuredBannerRect;
    featuredBannerRect = CGRectMake((bannerWidth-bw)/2, (bannerHeight-bh)/2, bw, bh);
    bannerContainerRow.frame = featuredBannerRect;

    [self.introductionView addSubview:bannerContainerRow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // bgm button
    [self updateBGMButton];

    // data
    if (!loading) {
        loading = YES;
        [self loadDataWithMessage:NO updateCategories:YES];
    }
    
    // rounded page title
    self.btnPageTitle.layer.cornerRadius = self.btnPageTitle.frame.size.height / 2;
    
    // register orientation changed event listener
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    // register keyboard event listener
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.introductionView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    // banner
    bannerContainerRow = [[FeaturedBannerRow alloc] init];
    
    bannerView = [[iCarousel alloc] initWithFrame:CGRectZero];
    bannerView.type = iCarouselTypeCoverFlow;
    bannerView.delegate = self;
    bannerView.dataSource = self;
    bannerView.decelerationRate = 0.5;
    [bannerContainerRow.contentView addSubview:bannerView];
    
    [bannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [bannerContainerRow.contentView addConstraints:[NSLayoutConstraint
                                                    constraintsWithVisualFormat:@"H:|-0-[bannerView]-0-|"
                                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                                    metrics:nil
                                                    views:NSDictionaryOfVariableBindings(bannerView)]];
    [bannerContainerRow.contentView addConstraints:[NSLayoutConstraint
                                                    constraintsWithVisualFormat:@"V:|-0-[bannerView]-0-|"
                                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                                    metrics:nil
                                                    views:NSDictionaryOfVariableBindings(bannerView)]];
    
    bannerTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(stepBanner) userInfo:nil repeats:YES];
    
    // dismiss keyboard when touching outside of search box
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    int bannerWidth, bannerHeight, bw, bh;
    float rate;
    bannerWidth = [UIScreen mainScreen].bounds.size.width;
    bannerHeight = [UIScreen mainScreen].bounds.size.height;
    if (bannerWidth > 1000 || bannerHeight > 1000) {
        rate = 1;
    } else {
        rate = 1.5;
    }
    
    bannerWidth = bannerWidth*0.83; bannerHeight = bannerHeight*0.57;
    bw = bannerWidth / rate; bh = bw / BANNER_ITEM_WIDTH_HEIGHT_RATIO;
    
    bannerContainerRow.backgroundColor = [UIColor clearColor];
    
    CGRect featuredBannerRect;
    featuredBannerRect = CGRectMake((bannerWidth-bw)/2, (bannerHeight-bh)/2, bw, bh);
    bannerContainerRow.frame = featuredBannerRect;
    
    [self.introductionView addSubview:bannerContainerRow];
}

- (void)loadDataWithMessage:(BOOL)message updateCategories:(BOOL)updateCategories {
    // load category data
    if (updateCategories) {
        [[AppSettings sharedInstance] loadCategoriesWithCompletionHandler:^(NSArray *categories) {
            self.categories = categories;
        }];
    }

    // waiting message
    if (message)
        [Common showWaitingViewWithMessage:NSLocalizedString(@"Waiting", @"") container:self.view];
    
    // load featured data
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/featured", SERVER_URL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        loading = NO;
        
        // hide offline message
        self.viewOffline.hidden = YES;
        
        // close waiting message
        if (message)
            [Common removeWaitingViewFromContainer:self.view];

        // save the result
        self.bannerData = [responseObject objectForKey:@"banner"];
        self.featuredData = [responseObject objectForKey:@"featured"];

        // reload UI
        [bannerView reloadData];
        [self.featuredTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//        // show offline message
//        self.viewOffline.hidden = NO;
//        
//        // close waiting message
//        if (message) {
//            loading = NO;
//            [Common removeWaitingViewFromContainer:self.view];
//        } else {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                [self loadDataWithMessage:message updateCategories:updateCategories];
//            });
//        }
    }];
    
    [operation start];
}

- (void)orientationChanged:(NSNotification *)notification {
    [bannerView reloadData];
}

- (void)stepBanner {
    if (transitionCount < 3) {
        [bannerView scrollByNumberOfItems:1 duration:0.5];
    }
    transitionCount += 1;
}

- (IBAction)categoryClicked:(id)sender {
    ActionSheetStringPicker* picker = [[ActionSheetStringPicker alloc] initWithTitle:NSLocalizedString(@"category", nil)
                                                                                rows:[self.categories valueForKey:@"name"]
                                                                    initialSelection:0
                                                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                                                               if (self.categories != nil) {
                                                                                   NSString* categoryId = [[self.categories objectAtIndex:selectedIndex] objectForKey:@"id"];
                                                                                   [self performSegueWithIdentifier:@"showCategorized" sender:categoryId];
                                                                               }
                                                                           }
                                                                         cancelBlock:nil
                                                                              origin:sender];
    
    [picker showActionSheetPicker];
}

- (IBAction)libraryClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)purchasedClicked:(id)sender {
    [self performSegueWithIdentifier:@"showPurchased" sender:nil];
}

- (IBAction)shareClicked:(id)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Share", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles: NSLocalizedString(@"Facebook", @""), NSLocalizedString(@"Twitter", @""), NSLocalizedString(@"Instagram", @""), NSLocalizedString(@"WhatsApp", @""), nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [popup showFromRect:self.btnShare.frame inView:self.view animated:YES];
    else
        [popup showInView:self.view];
}

- (IBAction)bgmClicked:(id)sender {
    [AppSettings sharedInstance].bgmOn = ![AppSettings sharedInstance].bgmOn;
    if ([AppSettings sharedInstance].bgmOn)
        [[AppSettings sharedInstance] playBGM];
    else
        [[AppSettings sharedInstance] stopBGM];
    
    [self updateBGMButton];
}

- (void)updateBGMButton {
    if ([AppSettings sharedInstance].bgmOn)
        [self.btnBGM setImage:[UIImage imageNamed:@"button_bgm_on"] forState:UIControlStateNormal];
    else
        [self.btnBGM setImage:[UIImage imageNamed:@"button_bgm_off"] forState:UIControlStateNormal];
}

- (void)seeAllClicked:(NSInteger)index {
    [self performSegueWithIdentifier:@"showSpecific" sender:[NSNumber numberWithInteger:index]];
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

//#pragma mark - UIGestureRecognizerDelegate
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if (![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && ![otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
//        return YES;
//    }
//    
//    return NO;
//}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    if (textField == self.txtSearch) {
        // hide keyboard
        [textField resignFirstResponder];

        // goto search
        [self performSegueWithIdentifier:@"showSearch" sender:self.txtSearch.text];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // only banner
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // banner row
        return bannerContainerRow;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // make the background color of table view to transparent
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return tableView.frame.size.height;
    }
    
    return 0;
}

#pragma mark - iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.bannerData.count;
}

- (void)loadImageView:(__weak UIImageView*)imageView path:(NSString*)path {
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    [imageView setImageWithURLRequest:request
                     placeholderImage:[UIImage imageNamed:@"UnknownBannerImage"]
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  [UIView transitionWithView:imageView
                                                    duration:0.3
                                                     options:UIViewAnimationOptionTransitionCrossDissolve
                                                  animations:^{
                                                      imageView.image = image;
                                                  }
                                                  completion:NULL];
                              }
                              failure:^(NSURLRequest *request2, NSHTTPURLResponse *response2, NSError *error2) {
                                  [self loadImageView:imageView path:path];
                              }];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    @try {
        // get banner item's data at index
        NSDictionary* data = [self.bannerData objectAtIndex:index];
        
        // calculate width and height of banner item
        float w, h;
        if (isPhone) {
            h = carousel.frame.size.height * 1.0;
            w = h * BANNER_ITEM_WIDTH_HEIGHT_RATIO;
        } else {
            h = carousel.frame.size.height * 0.7;
            w = h * BANNER_ITEM_WIDTH_HEIGHT_RATIO;
        }

        // create new view if no view is available for recycling
        if (view == nil) {
            UIImageView* imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(0, 0, w, h);
            imageView.layer.cornerRadius = 10;
            imageView.layer.masksToBounds = YES;
            imageView.layer.borderWidth = 1;
            imageView.layer.borderColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1].CGColor;

            NSString *path = [data objectForKey:@"image"];
            [self loadImageView:imageView path:path];
            
            view = imageView;
        } else {
            UIImageView* imageView = (UIImageView*)view;

            NSString *path = [data objectForKey:@"image"];
            [self loadImageView:imageView path:path];
        }

        return view;
    } @catch (NSException* e) {
        return nil;
    }
}

#pragma mark - iCarouselDelegate

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    [self.txtSearch resignFirstResponder];
    if (carousel.currentItemIndex == index) {
        // get banner item's data at index
        NSDictionary* data = [self.bannerData objectAtIndex:index];
        NSString *bookId = [data objectForKey:@"link"];

        // show info dialog
        if (bookId != nil && ![bookId isEqualToString:@""])
            [self showInformationOfBook:bookId];
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option)
    {
        case iCarouselOptionWrap:
            return YES;
        case iCarouselOptionTilt:
            return value * 0.5;
        case iCarouselOptionSpacing:
            return isPhone ? value : value * 0.5;
        default:
            return value;
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[self.featuredData objectAtIndex:collectionView.tag] objectForKey:@"books"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // data for book
    NSDictionary* data = [[[self.featuredData objectAtIndex:collectionView.tag] objectForKey:@"books"] objectAtIndex:indexPath.item];
    
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
    NSDictionary* data = [[[self.featuredData objectAtIndex:collectionView.tag] objectForKey:@"books"] objectAtIndex:indexPath.item];
    NSString *bookId = [data objectForKey:@"id"];
    
    // show info dialog
    [self showInformationOfBook:bookId];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [Common shareOnFacebook:self];
        
    } else if (buttonIndex == 1) {
        [Common shareOnTwitter:self];
        
    } else if (buttonIndex == 2) {
        // share on Instagram
        
        // copy image to documents folder
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"instagram" ofType:@"jpg"];
        NSString *targetPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Tata.igo"];
        [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
        BOOL ret = [[NSFileManager defaultManager] copyItemAtPath:resourcePath toPath:targetPath error:nil];
        
        if (ret) {
            // present document interaction controller
            NSURL *igoURL = [NSURL fileURLWithPath:targetPath];
            docController = [UIDocumentInteractionController interactionControllerWithURL:igoURL];
            docController.delegate = self;
            docController.UTI = @"com.instagram.photo";
            
            ret = [docController presentOpenInMenuFromRect:self.btnShare.frame inView:self.view animated: YES ];
            if (!ret) {
                UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                                 message:NSLocalizedString(@"NoInstagramApp", @"")
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                                       otherButtonTitles: nil];
                [alert show];
            }
        } else {
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                             message:NSLocalizedString(@"UnknownError", @"")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                                   otherButtonTitles: nil];
            [alert show];
        }
        
    } else if (buttonIndex == 3) {
        [Common shareOnWhatsapp:self];
    }
}

#pragma mark - Navigation control
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString* segueId = [segue identifier];

    if ([segueId isEqualToString:@"showCategorized"]) {
        CategorizedViewController *categorizedVC = segue.destinationViewController;
        categorizedVC.categoryId = sender;

    } else if ([segueId isEqualToString:@"showSpecific"]) {
        int index = [sender intValue];
        NSDictionary* data = [self.featuredData objectAtIndex:index];
        NSString* specificId = [data objectForKey:@"id"];
        NSString* specificName = [data objectForKey:@"name"];

        SpecificViewController *specificVC = segue.destinationViewController;
        specificVC.specificId = specificId;
        specificVC.specificName = specificName;        

    } else if ([segueId isEqualToString:@"showSearch"]) {
        SearchViewController *searchVC = segue.destinationViewController;
        searchVC.keyword = sender;
    }
}

@end
