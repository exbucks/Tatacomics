//
//  TEasingFunction.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EasingType) {
    EasingTypeNone,
    EasingTypeExponential,
    EasingTypeSine,
    EasingTypeElastic,
    EasingTypeBounce,
    EasingTypeBack
};

typedef NS_ENUM(NSInteger, EasingMode) {
    EasingModeIn,
    EasingModeOut,
    EasingModeInOut
};

@interface TEasingFunction : NSObject

// EaseExponential Properties
@property (assign) double exponent;

// EaseBounce Properties
@property (assign) int bounces;
@property (assign) double bounciness;

// EaseElastic Properties
@property (assign) int oscillations;
@property (assign) double springiness;

// EaseBack Properties
@property (assign) double amplitude;

- (float)easeByType:(EasingType)type mode:(EasingMode)mode duration:(float)duration time:(float)time start:(float)startVal end:(float)endVal;

- (double)easeLinear:(double)t;
- (double)easeExponential:(double)t;
- (double)easeSine:(double)t;
- (double)easeElastic:(double)t;
- (double)easeBounce:(double)t;
- (double)easeBack:(double)t;
- (double)easeCircle:(double)t;
- (double)easeQuadratic:(double)t;
- (double)easeCubic:(double)t;
- (double)easeQuartic:(double)t;
- (double)easeQuintic:(double)t;

@end
