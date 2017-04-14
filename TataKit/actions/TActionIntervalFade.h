//
//  TActionIntervalFade.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInterval.h"
#import "TEasingFunction.h"

typedef NS_ENUM(NSInteger, FadeActionType) {
    FadeActionTypeTo,
    FadeActionTypeFromTo,
    FadeActionTypeIn,
    FadeActionTypeOut
};

@interface TActionIntervalFade : TActionInterval

@property (assign) FadeActionType   type;
@property (assign) float            startAlpha;
@property (assign) float            endAlpha;
@property (assign) EasingType       easingType;
@property (assign) EasingMode       easingMode;

@end
