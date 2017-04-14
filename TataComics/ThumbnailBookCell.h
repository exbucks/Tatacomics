//
//  ThumbnailBookCell
//  TataComics
//
//  Created by Albert Li on 11/25/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbnailBookCell : UICollectionViewCell

@property (assign, nonatomic) BOOL marked;

@property (weak, nonatomic) IBOutlet UIImageView *imgCover;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgSelection;

@end
