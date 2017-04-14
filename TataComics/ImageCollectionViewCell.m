//
//  ImageCollectionViewCell.m
//  TataComics
//
//  Created by Albert on 12/3/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@implementation ImageCollectionViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.bounds.size.width == 1)
        self.hidden = YES;
    else
        self.hidden = NO;
}

@end
