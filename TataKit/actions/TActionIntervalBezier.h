//
//  TActionIntervalBezier.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInterval.h"
#import "TEasingFunction.h"

typedef NS_ENUM(NSInteger, BezierActionType) {
    BezierActionTypeTo,
    BezierActionTypeBy
};

@interface TActionIntervalBezier : TActionInterval

@property (assign) BezierActionType     type;
@property (assign) CGPoint              point1;
@property (assign) CGPoint              point2;
@property (assign) CGPoint              point3;
@property (assign) EasingType           easingType;
@property (assign) EasingMode           easingMode;

@end
