//
//  FeaturedSectionCell.h
//  TataComics
//
//  Created by Albert Li on 11/20/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SeeAllDelegate <NSObject>

@required

- (void)seeAllClicked:(NSInteger)index;

@end

//========================================================================================================================================//

@interface FeaturedCommonRow : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnSeeAll;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionBooks;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

- (void)setSeeAllDelegate:(id<SeeAllDelegate>)delegate index:(NSInteger)index;

- (IBAction)seeAllClicked:(id)sender;

@end
