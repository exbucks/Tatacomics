    //
//  BookInfoViewController.m
//  TataComics
//
//  Created by Albert on 12/2/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "BookInfoViewController.h"
#import "ImageCollectionViewCell.h"
#import "BookViewController.h"

#import "AFNetworking.h"
#import "LLACircularProgressView.h"
#import "LLACircularProgressView+AFNetworking.h"

#import "AppSettings.h"
#import "IAPHelper.h"
#import "Common.h"

typedef NS_ENUM(NSUInteger, PurchaseButtonState) {
    PurchaseButtonStatePurchase,
    PurchaseButtonStateUpdate,
    PurchaseButtonStateGet,
    PurchaseButtonStateOpen
};

@interface BookInfoViewController () {
    NSString* bookId;
    NSString* bundleId;
    NSMutableDictionary* screenshotSizes;
}

@end

@implementation BookInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    bookId = [self.data objectForKey:@"id"];
    bundleId = [self.data objectForKey:@"bundle"];
    screenshotSizes = [[NSMutableDictionary alloc] init];

    // show informations
    NSString *iconPath = [self.data objectForKey:@"icon"];
    [self.imgIcon setImageWithURL:[NSURL URLWithString:iconPath]];
    
    [self.imgProgDownloadingBackground setImageWithURL:[NSURL URLWithString:iconPath]];
    self.progDownloading.pieStyle = YES;
    self.progDownloading.reversePie = YES;
    
    self.lblTitle.text = [self.data objectForKey:@"title"];
    self.lblAuthor.text = [self.data objectForKey:@"author"];
    self.lblDescription.text = [self.data objectForKey:@"description"];
    self.btnPurchase.tag = PurchaseButtonStatePurchase;
    
//    [Common makeInformationView:self.viewInformation info:[self.data objectForKey:@"information"] fontSize:13];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if(screenRect.size.width > 760.00 ) {
        [self.lblTitle setFont:[UIFont systemFontOfSize: 27]];
        [self.lblAuthor setFont:[UIFont systemFontOfSize:21]];
        [self.lblPrice setFont:[UIFont systemFontOfSize:24]];
        [self.lblDescriptionTitle setFont:[UIFont systemFontOfSize:25]];
        [self.lblDescription setFont:[UIFont systemFontOfSize:25]];
    } else {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(downloadBookStarting:) name:DownloadBookStartingNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(downloadBookStarted:) name:DownloadBookStartedNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(downloadBookCompleted:) name:DownloadBookCompletedNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(downloadBookFailed:) name:DownloadBookFailedNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(downloadBookCancelled:) name:DownloadBookCancelledNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(productRestored:) name:IAPHelperProductRestoredNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(productFailed:) name:IAPHelperProductFailedNotification object:nil];

    // check downloading binary
    AppSettings* appSettings = [AppSettings sharedInstance];
    if ([appSettings.downloadingBooks objectForKey:bookId]) {
        if ([appSettings downloadingTaskOfBook:bookId] != nil)
            [notificationCenter postNotificationName:DownloadBookStartedNotification object:nil userInfo:@{@"book": bookId}];
        else
            [notificationCenter postNotificationName:DownloadBookStartingNotification object:nil userInfo:@{@"book": bookId}];
    } else {
        [self updatePurchaseButton];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    bounceCount = 0;
    scale = 1.0;
    btnDownloadRect.size.width = screenRect.size.width * 0.113;
    btnDownloadRect.size.height = screenRect.size.height * 0.157;
    btnDownloadRect.origin.x = screenRect.size.width * 0.227;
    btnDownloadRect.origin.y = screenRect.size.height * 0.167;
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)timerFired
{
    if (directionFlag && bounceCount < 5) {
        scale += 0.025;
        CGRect btnDownloadFrame;
        btnDownloadFrame = CGRectMake(btnDownloadRect.origin.x - btnDownloadRect.size.width * (scale-1)/2, btnDownloadRect.origin.y - btnDownloadRect.size.height * (scale-1)/2, scale * btnDownloadRect.size.width, scale * btnDownloadRect.size.height);
        [self.btnPurchase setFrame:btnDownloadFrame];
        bounceCount += 1;
    } else if (directionFlag && bounceCount == 5) {
        directionFlag = false;
    } else if (!directionFlag && bounceCount > 0) {
        scale -= 0.025;
        CGRect btnDownloadFrame;
        btnDownloadFrame = CGRectMake(btnDownloadRect.origin.x + btnDownloadRect.size.width * (1 - scale)/2, btnDownloadRect.origin.y + btnDownloadRect.size.height * (1 - scale)/2, scale * btnDownloadRect.size.width, scale * btnDownloadRect.size.height);
        [self.btnPurchase setFrame:btnDownloadFrame];
        bounceCount -= 1;
    } else if (!bounceCount && bounceCount == 0) {
        directionFlag = true;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:DownloadBookStartingNotification object:nil];
    [notificationCenter removeObserver:self name:DownloadBookStartedNotification object:nil];
    [notificationCenter removeObserver:self name:DownloadBookCompletedNotification object:nil];
    [notificationCenter removeObserver:self name:DownloadBookFailedNotification object:nil];
    [notificationCenter removeObserver:self name:DownloadBookCancelledNotification object:nil];
    [notificationCenter removeObserver:self name:IAPHelperProductPurchasedNotification object:nil];
    [notificationCenter removeObserver:self name:IAPHelperProductRestoredNotification object:nil];
    [notificationCenter removeObserver:self name:IAPHelperProductFailedNotification object:nil];

    NSURLSessionDownloadTask* task = [[AppSettings sharedInstance] downloadingTaskOfBook:bookId];
    if (task != nil)
        [self.progDownloading clearProgressWithDownloadProgressOfTask:task];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.imgProgDownloadingBackground.layer.cornerRadius = self.imgProgDownloadingBackground.frame.size.width / 2;
    self.imgProgDownloadingBackground.layer.masksToBounds = YES;

    [self.clvScreenshot.collectionViewLayout invalidateLayout];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (IBAction)purchaseClicked:(id)sender {

    if (self.btnPurchase.tag == PurchaseButtonStatePurchase) {

        // show waiting message
        [Common showWaitingViewWithMessage:NSLocalizedString(@"Waiting", @"") container:self.view];
        
        if ([[self.data objectForKey:@"price"] doubleValue] == 0) {
            NSNotification* notification = [[NSNotification alloc] initWithName:@"FreeDown" object:bundleId userInfo:nil];
            [self productPurchased:notification];
        } else {
            // perform buying the IAP
            [[IAPHelper sharedInstance] buyProduct:self.skProduct];
        }
        
    } else if (self.btnPurchase.tag == PurchaseButtonStateGet || self.btnPurchase.tag == PurchaseButtonStateUpdate) {
	
        // start download
        [[AppSettings sharedInstance] downloadBook:bookId];

    } else if (self.btnPurchase.tag == PurchaseButtonStateOpen) {

        // show book
        BookViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"bookViewController"];
        vc.identifier = bookId;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)productPurchased:(NSNotification *)notification {
    // hide waiting message
    [Common removeWaitingViewFromContainer:self.view];
    
    NSString *productIdentifier = notification.object;
    if ([productIdentifier isEqualToString:bundleId]) {
        // start download
        [[AppSettings sharedInstance] downloadBook:bookId];
        [self updatePurchaseButton];
    }
}

- (void)productRestored:(NSNotification *)notification {
    // hide waiting message
    [Common removeWaitingViewFromContainer:self.view];
    
    NSString * productIdentifier = notification.object;
    if ([productIdentifier isEqualToString:bundleId]) {
        // start download
        [[AppSettings sharedInstance] downloadBook:bookId];
    }
}

- (void)productFailed:(NSNotification*)notification {
    // hide waiting message
    [Common removeWaitingViewFromContainer:self.view];
    
    // don't need to show erroe message, because IAPHelper::failedTransaction will show error message before this.
    [self updatePurchaseButton];
}

- (IBAction)closeClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)stopDownloadingClicked:(id)sender {
    [[AppSettings sharedInstance] stopDownloadingBook:bookId];
}

- (void)updatePurchaseButton {
    // check downloading, downloaded, updating
    AppSettings* appSettings = [AppSettings sharedInstance];
    if ([appSettings.downloadingBooks objectForKey:bookId]) {
        // hide purhcase button and show progress
        self.btnPurchase.hidden = YES;
        self.imgProgDownloadingBackground.hidden = NO;
        self.progDownloading.hidden = NO;
        self.progDownloading.progress = 0;

        [self.lblPrice setText:NSLocalizedString(@"Downloading", @"")];
    } else {
        // hide progress and show purchase button
        self.imgProgDownloadingBackground.hidden = YES;
        self.progDownloading.hidden = YES;
        self.btnPurchase.hidden = NO;
        
        // check local book exists
        NSDictionary* localBook = [appSettings localBookInfo:bookId];
        if (localBook != nil) {
            NSString* localVersion = [localBook objectForKey:@"version"];
            NSString* remoteVersion = [self.data objectForKey:@"version"];
            // check new version exists
            if ([remoteVersion compare:localVersion options:NSNumericSearch] == NSOrderedDescending) {
                [self.btnPurchase setBackgroundImage:[UIImage imageNamed:@"ButtonDownload"] forState:UIControlStateNormal];
                [self.btnPurchase setTag:PurchaseButtonStateUpdate];
                [self.lblPrice setText:NSLocalizedString(@"Update", @"")];
            } else {
                [self.btnPurchase setBackgroundImage:[UIImage imageNamed:@"ButtonStart"] forState:UIControlStateNormal];
                [self.btnPurchase setTag:PurchaseButtonStateOpen];
                [self.lblPrice setText:NSLocalizedString(@"Open", @"")];
            }
        } else {
            
            // purchase button's image
            [self.btnPurchase setBackgroundImage:[UIImage imageNamed:@"ButtonDownload"] forState:UIControlStateNormal];
            
            // if the book was purchased by checking Local Storage
            if ([[IAPHelper sharedInstance] productPurchased:bundleId]) {

                // purchase button's action tag
                [self.btnPurchase setTag:PurchaseButtonStateGet];
                
                // initial title is "Get"
                [self.lblPrice setText:NSLocalizedString(@"Get", @"")];

            } else {

                // purchase button's action tag
                [self.btnPurchase setTag:PurchaseButtonStatePurchase];

                // title of purchase button
                if ([[self.data objectForKey:@"price"] doubleValue] == 0 || self.skProduct.price.floatValue == 0) {
                    [self.lblPrice setText:NSLocalizedString(@"Free", @"")];
                } else {
                    NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
                    [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                    [priceFormatter setLocale:self.skProduct.priceLocale];
                    
                    NSString *price = [priceFormatter stringFromNumber:self.skProduct.price];
                    [self.lblPrice setText:price];
                }
            }
        }
    }
}

#pragma mark - Download Book events

- (void)downloadBookStarting:(NSNotification*)notification {
    if ([bookId isEqualToString:[notification.userInfo objectForKey:@"book"]]) {
        // purchase button
        [self updatePurchaseButton];
    }
}

- (void)downloadBookStarted:(NSNotification*)notification {
    if ([bookId isEqualToString:[notification.userInfo objectForKey:@"book"]]) {
        // purchase button
        [self updatePurchaseButton];

        NSURLSessionDownloadTask* task = [[AppSettings sharedInstance] downloadingTaskOfBook:bookId];
        if (task != nil) {
            [self.progDownloading setProgressWithDownloadProgressOfTask:task animated:NO];
        }
    }
}

- (void)downloadBookCompleted:(NSNotification*)notification {
    if ([bookId isEqualToString:[notification.userInfo objectForKey:@"book"]]) {
        // purchase button
        [self updatePurchaseButton];
        
        if ([[self.data objectForKey:@"price"] doubleValue] == 0) {
            
            // send the purchase data for statistics
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSString *url = [NSString stringWithFormat:@"%@/api/purchased", SERVER_URL];
            NSDictionary *parameters = @{
                                         @"book" : bundleId,
                                         @"currency" : @"USD",
                                         @"symbol" : @"$",
                                         @"money" : @([[self.data objectForKey:@"price"] doubleValue]),
                                         };
            [manager POST:url parameters:parameters success:nil failure:nil];
            
        } else {
            // get IAP info such as price from App Store
            [[IAPHelper sharedInstance] requestProducts:[NSSet setWithObjects:bundleId, nil] completionHandler:^(BOOL success, NSArray *products) {
                
                if (success) {
                    SKProduct* skProduct = [products objectAtIndex:0];
                    
                    // send the purchase data for statistics
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    NSString *url = [NSString stringWithFormat:@"%@/api/purchased", SERVER_URL];
                    NSDictionary *parameters = @{
                                                 @"book" : bundleId,
                                                 @"currency" : [skProduct.priceLocale objectForKey:NSLocaleCurrencyCode],
                                                 @"symbol" : [skProduct.priceLocale objectForKey:NSLocaleCurrencySymbol	],
                                                 @"money" : [NSNumber numberWithDouble:skProduct.price.doubleValue],
                                                 };
                    [manager POST:url parameters:parameters success:nil failure:nil];
                }
            }];
        }
    }
}

- (void)downloadBookFailed:(NSNotification*)notification {
    if ([bookId isEqualToString:[notification.userInfo objectForKey:@"book"]]) {
        // purchase button
        [self updatePurchaseButton];
        
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                         message:NSLocalizedString(@"DownloadFailed", @"")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                               otherButtonTitles: nil];
        [alert show];
    }
}

- (void)downloadBookCancelled:(NSNotification*)notification {
    if ([bookId isEqualToString:[notification.userInfo objectForKey:@"book"]]) {
        // purchase button
        [self updatePurchaseButton];
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray* screenshots = [self.data objectForKey:@"screenshot"];
    return screenshots.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // one screenshot
    NSArray* screenshots = [self.data objectForKey:@"screenshot"];
    NSString* screenshot = [screenshots objectAtIndex:indexPath.item];

    // make the cell
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCollectionViewCell" forIndexPath:indexPath];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:screenshot]];
    __weak UIImageView* _imageView = cell.imageView;
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       _imageView.image = image;
                                       [screenshotSizes setObject:[NSValue valueWithCGSize:image.size] forKey:[NSNumber numberWithInteger:indexPath.item]];
                                       [self.clvScreenshot.collectionViewLayout invalidateLayout];
                                   }
                                   failure:NULL];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [screenshotSizes objectForKey:[NSNumber numberWithInteger:indexPath.item]];
    float w, h = collectionView.bounds.size.height;
    if (item != nil) {
        CGSize size = [item CGSizeValue];
        w = h * size.width / size.height;
    } else {
        w = 1;
    }
    
    return CGSizeMake(w, h);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger currentIndex = self.clvScreenshot.contentOffset.x / self.clvScreenshot.frame.size.width*1.5;
    self.pgcIndex.currentPage = currentIndex;
}

@end
