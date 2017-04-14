//
//  FeaturedViewController.h
//  TataComics
//
//  Created by Albert Li on 11/15/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "FeaturedCommonRow.h"

@interface FeaturedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, iCarouselDataSource, iCarouselDelegate, UICollectionViewDataSource, UICollectionViewDelegate, SeeAllDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate> {
    int transitionCount;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *introductionView;



@property (weak, nonatomic) IBOutlet UIButton *btnCategory;
@property (weak, nonatomic) IBOutlet UIButton *btnLibrary;
@property (weak, nonatomic) IBOutlet UIButton *btnPurchased;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIButton *btnBGM;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;

@property (weak, nonatomic) IBOutlet UIButton *btnPageTitle;
@property (weak, nonatomic) IBOutlet UITableView *featuredTableView;

@property (weak, nonatomic) IBOutlet UIView *viewOffline;

@property (strong, atomic) NSArray *categories;
@property (strong, atomic) NSArray *bannerData;
@property (strong, atomic) NSArray *featuredData;

- (IBAction)categoryClicked:(id)sender;
- (IBAction)libraryClicked:(id)sender;
- (IBAction)purchasedClicked:(id)sender;
- (IBAction)shareClicked:(id)sender;
- (IBAction)bgmClicked:(id)sender;

@end
