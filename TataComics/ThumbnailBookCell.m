//
//  ThumbnailBookCell.m
//  TataComics
//
//  Created by Albert Li on 11/25/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "ThumbnailBookCell.h"

@implementation ThumbnailBookCell

- (void)setMarked:(BOOL)marked {
    _marked = marked;

    if (marked) {
        self.imgCover.alpha = 0.6;
        if (self.imgSelection != nil)
            self.imgSelection.hidden = NO;
    } else {
        self.imgCover.alpha = 1;
        if (self.imgSelection != nil)
            self.imgSelection.hidden = YES;
    }
}

@end
