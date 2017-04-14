//
//  TActionIntervalMove.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInterval.h"
#import "TEasingFunction.h"

typedef NS_ENUM(NSInteger, MoveActionType) {
    MoveActionTypeTo,
    MoveActionTypeBy
};

@interface TActionIntervalMove : TActionInterval

@property (assign) MoveActionType   type;
@property (assign) CGPoint          position;
@property (assign) EasingType       easingType;
@property (assign) EasingMode       easingMode;

@end
