//
//  TActionIntervalRotate.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionIntervalRotate.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TAnimation.h"
#import "TSequence.h"
#import "TActor.h"
#import "TLayer.h"

@implementation TActionIntervalRotate {
    float run_startAngle;
    float run_endAngle;
    TEasingFunction* run_easingFunction;
}

- (id)init {
    if (self = [super init]) {
        self.name = @"Rotate";
        self.startingColor = [UIColor colorWithRed:221/255.0 green:255/255.0 blue:249/255.0 alpha:1];
        self.endingColor = [UIColor colorWithRed:209/255.0 green:255/255.0 blue:247/255.0 alpha:1];
        self.icon = [UIImage imageNamed:@"icon_action_rotate"];
        
        self.type = RotateActionTypeTo;
        self.angle = 0;
        self.easingType = EasingTypeNone;
        self.easingMode = EasingModeIn;
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionIntervalRotate* targetAction = (TActionIntervalRotate*)target;
    targetAction.type = self.type;
    targetAction.angle = self.angle;
    targetAction.easingType = self.easingType;
    targetAction.easingMode = self.easingMode;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionIntervalRotate"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        _type           = [TUtil parseIntXElement:[xml childNamed:@"Type"] default:RotateActionTypeTo];
        _angle          = [TUtil parseIntXElement:[xml childNamed:@"Angle"] default:0];
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

- (void)reset:(long long)time {
    [super reset:time];
    
    TLayer* layer = self.sequence.animation.layer;
    if ([layer isKindOfClass:TActor.class]) {
        
        TActor* target = (TActor*)layer;
        
        run_startAngle = target.rotation;
        
        if (self.type == RotateActionTypeTo)
            run_endAngle = self.angle;
        else if (self.type == RotateActionTypeBy)
            run_endAngle = run_startAngle + self.angle;
        
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
        target.rotation = [run_easingFunction easeByType:self.easingType mode:self.easingMode duration:self.duration time:elapsed start:run_startAngle end:run_endAngle];
    }
    
    return [super step:delegate time:time];
}

@end
