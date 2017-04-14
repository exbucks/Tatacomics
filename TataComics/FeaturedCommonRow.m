//
//  FeaturedSectionCell.m
//  TataComics
//
//  Created by Albert Li on 11/20/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "FeaturedCommonRow.h"

@interface FeaturedCommonRow() {
    id<SeeAllDelegate>  seeAllDelegate;
}

@end

@implementation FeaturedCommonRow

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index {
    self.collectionBooks.dataSource = dataSourceDelegate;
    self.collectionBooks.delegate = dataSourceDelegate;
    self.collectionBooks.tag = index;
    
    [self.collectionBooks reloadData];
}

- (void)setSeeAllDelegate:(id<SeeAllDelegate>)delegate index:(NSInteger)index {
    seeAllDelegate = delegate;
    self.btnSeeAll.tag = index;
}

- (IBAction)seeAllClicked:(id)sender {
    if ([seeAllDelegate respondsToSelector:@selector(seeAllClicked:)]) {
        [seeAllDelegate seeAllClicked:self.btnSeeAll.tag];
    }
}

@end
