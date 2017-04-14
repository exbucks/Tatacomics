//
//  TActionIntervalFade.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionIntervalFade.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TAnimation.h"
#import "TSequence.h"
#import "TLayer.h"

@implementation TActionIntervalFade {
    float run_startAlpha;
    float run_endAlpha;
    TEasingFunction* run_easingFunction;
}

- (id)init {
    if (self = [super init]) {
        self.name = @"Fade";
        self.startingColor = [UIColor colorWithRed:226/255.0 green:226/255.0 blue:226/255.0 alpha:1];
        self.endingColor = [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1];
        self.icon = [UIImage imageNamed:@"icon_action_fade"];
        
        self.type = FadeActionTypeTo;
        self.startAlpha = 0;
        self.endAlpha = 1;
        self.easingType = EasingTypeNone;
        self.easingMode = EasingModeIn;
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionIntervalFade* targetAction = (TActionIntervalFade*)target;
    targetAction.type = self.type;
    targetAction.startAlpha = self.startAlpha;
    targetAction.endAlpha = self.endAlpha;
    targetAction.easingType = self.easingType;
    targetAction.easingMode = self.easingMode;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionIntervalFade"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        _type           = [TUtil parseIntXElement:[xml childNamed:@"Type"] default:FadeActionTypeTo];
        _startAlpha     = [TUtil parseFloatXElement:[xml childNamed:@"StartAlpha"] default:0];
        _endAlpha       = [TUtil parseFloatXElement:[xml childNamed:@"EndAlpha"] default:0];
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
    switch (self.type) {
        case FadeActionTypeTo:
            run_startAlpha = layer.alpha;
            run_endAlpha = self.endAlpha;
            break;
        case FadeActionTypeFromTo:
            run_startAlpha = self.startAlpha;
            run_endAlpha = self.endAlpha;
            break;
        case FadeActionTypeIn:
            run_startAlpha = layer.alpha;
            run_endAlpha = 1;
            break;
        case FadeActionTypeOut:
            run_startAlpha = layer.alpha;
            run_endAlpha = 0;
            break;
    }
    
    run_easingFunction = [[TEasingFunction alloc] init];
}

- (BOOL)step:(id<TTataDelegate>)delegate time:(long long)time {

    float elapsed = time - self.run_startTime;
    if (elapsed > self.duration)
        elapsed = self.duration;
    
    TLayer* layer = self.sequence.animation.layer;
    layer.alpha = [run_easingFunction easeByType:self.easingType mode:self.easingMode duration:self.duration time:elapsed start:run_startAlpha end:run_endAlpha];
    
    return [super step:delegate time:time];
}

@end
