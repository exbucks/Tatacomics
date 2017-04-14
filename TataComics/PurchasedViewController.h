//
//  PurchasedViewController.h
//  TataComics
//
//  Created by Albert Li on 11/15/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface PurchasedViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, atomic) NSArray *booksData;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *booksCollectionView;

@property (weak, nonatomic) IBOutlet UIButton *btnLibrary;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnPageTitle;

- (IBAction)backClicked:(id)sender;
- (IBAction)libraryClicked:(id)sender;

@end
