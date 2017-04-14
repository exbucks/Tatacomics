//
//  InsetTextField.m
//  TataComics
//
//  Created by Albert on 1/22/15.
//  Copyright (c) 2015 Tataland. All rights reserved.
//

#import "InsetTextField.h"

@implementation InsetTextField

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + self.insetLeft, bounds.origin.y + self.insetTop, bounds.size.width - self.insetLeft - self.insetRight, bounds.size.height - self.insetTop - self.insetBottom);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + self.insetLeft, bounds.origin.y + self.insetTop, bounds.size.width - self.insetLeft - self.insetRight, bounds.size.height - self.insetTop - self.insetBottom);
}

@end
