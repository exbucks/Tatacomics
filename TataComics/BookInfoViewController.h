//
//  BookInfoViewController.h
//  TataComics
//
//  Created by Albert on 12/2/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@class LLACircularProgressView;

@interface BookInfoViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate> {
    int     bounceCount;
    bool    directionFlag;
    float   scale;
    CGRect  btnDownloadRect;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAuthor;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnPurchase;
@property (weak, nonatomic) IBOutlet UICollectionView *clvScreenshot;
@property (weak, nonatomic) IBOutlet UILabel *lblDescriptionTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@property (weak, nonatomic) IBOutlet UIPageControl *pgcIndex;


@property (weak, nonatomic) IBOutlet UIView *viewInformation;

@property (weak, nonatomic) IBOutlet UIImageView *imgProgDownloadingBackground;
@property (weak, nonatomic) IBOutlet LLACircularProgressView *progDownloading;

@property (strong, nonatomic) NSDictionary* data;
@property (strong, nonatomic) SKProduct* skProduct;

- (IBAction)purchaseClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;
- (IBAction)stopDownloadingClicked:(id)sender;

@end
