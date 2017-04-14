//
//  TActionIntervalScale.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInterval.h"
#import "TEasingFunction.h"

typedef NS_ENUM(NSInteger, ScaleActionType) {
    ScaleActionTypeTo,
    ScaleActionTypeBy
};

@interface TActionIntervalScale : TActionInterval

@property (assign) ScaleActionType      type;
@property (assign) CGSize               scale;
@property (assign) EasingType           easingType;
@property (assign) EasingMode           easingMode;

@end
