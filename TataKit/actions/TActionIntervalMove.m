//
//  TActionIntervalMove.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionIntervalMove.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TAnimation.h"
#import "TSequence.h"
#import "TActor.h"
#import "TLayer.h"

@implementation TActionIntervalMove {
    CGPoint run_startPos;
    CGPoint run_endPos;
    TEasingFunction* run_easingFunction;
}

- (id)init {
    if (self = [super init]) {
        self.name = @"Move";
        self.startingColor = [UIColor colorWithRed:205/255.0 green:243/255.0 blue:255/255.0 alpha:1];
        self.endingColor = [UIColor colorWithRed:188/255.0 green:239/255.0 blue:255/255.0 alpha:1];
        self.icon = [UIImage imageNamed:@"icon_action_move"];
        
        self.type = MoveActionTypeTo;
        self.position = CGPointZero;
        self.easingType = EasingTypeNone;
        self.easingMode = EasingModeIn;
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionIntervalMove* targetAction = (TActionIntervalMove*)target;
    targetAction.type = self.type;
    targetAction.position = self.position;
    targetAction.easingType = self.easingType;
    targetAction.easingMode = self.easingMode;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionIntervalMove"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        _type           = [TUtil parseIntXElement:[xml childNamed:@"Type"] default:MoveActionTypeTo];
        _position.x     = [TUtil parseFloatXElement:[xml childNamed:@"PositionX"] default:0];
        _position.y     = [TUtil parseFloatXElement:[xml childNamed:@"PositionY"] default:0];
        _easingType     = [TUtil parseIntXElement:[xml childNamed:@"EasingType"] default:EasingTypeNone];
        _easingMode     = [TUtil parseIntXElement:[xml childNamed:@"EasingMode"] default:EasingModeIn];

        return YES;
    } @catch (NSException* e) {
        NSLog(@"Error: %@", e);
        return NO;
    }
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

#pragma mark - Launch Methods

- (void)reset:(long long)time {
    [super reset:time];
    
    TLayer* layer = self.sequence.animation.layer;
    if ([layer isKindOfClass:TActor.class]) {
        TActor* target = (TActor*)layer;

        run_startPos = target.location;
        
        if (self.type == MoveActionTypeTo)
            run_endPos = self.position;
        else if (self.type == MoveActionTypeBy)
            run_endPos = CGPointMake(run_startPos.x + self.position.x, run_startPos.y + self.position.y);
        
        run_easingFunction = [[TEasingFunction alloc] init];
    }
}

- (BOOL)step:(id<TTataDelegate>)delegate time:(long long)time {
    
    float elapsed = time - self.run_startTime;
    if (elapsed > self.duration)
        elapsed = self.duration;
    
    TLayer* layer = self.sequence.animation.layer;
    if ([layer isKindOfClass:TActor.class]) {
        TActor* target = (TActor*)layer;
        float x = [run_easingFunction easeByType:self.easingType mode:self.easingMode duration:self.duration time:elapsed start:run_startPos.x end:run_endPos.x];
        float y = [run_easingFunction easeByType:self.easingType mode:self.easingMode duration:self.duration time:elapsed start:run_startPos.y end:run_endPos.y];
        target.location = CGPointMake(x, y);
    }
    
    return [super step:delegate time:time];
}

@end
