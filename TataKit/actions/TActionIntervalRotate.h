//
//  TActionIntervalRotate.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInterval.h"
#import "TEasingFunction.h"
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, RotateActionType) {
    RotateActionTypeTo,
    RotateActionTypeBy
};

@interface TActionIntervalRotate : TActionInterval

@property (assign) RotateActionType     type;
@property (assign) int                  angle;
@property (assign) EasingType           easingType;
@property (assign) EasingMode           easingMode;

@end
