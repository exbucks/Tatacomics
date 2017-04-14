//
//  InsetTextField.h
//  TataComics
//
//  Created by Albert on 1/22/15.
//  Copyright (c) 2015 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface InsetTextField : UITextField

@property (nonatomic, assign) IBInspectable NSInteger insetTop;
@property (nonatomic, assign) IBInspectable NSInteger insetBottom;
@property (nonatomic, assign) IBInspectable NSInteger insetLeft;
@property (nonatomic, assign) IBInspectable NSInteger insetRight;

@end
