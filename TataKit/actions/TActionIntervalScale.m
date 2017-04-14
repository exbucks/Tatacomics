//
//  TActionIntervalScale.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionIntervalScale.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TAnimation.h"
#import "TSequence.h"
#import "TActor.h"
#import "TLayer.h"

@implementation TActionIntervalScale {
    CGSize run_startScale;
    CGSize run_endScale;
    TEasingFunction* run_easingFunction;
}

- (id)init {
    if (self = [super init]) {
        self.name = @"Scale";
        self.startingColor = [UIColor colorWithRed:255/255.0 green:247/255.0 blue:221/255.0 alpha:1];
        self.endingColor = [UIColor colorWithRed:255/255.0 green:245/255.0 blue:220/255.0 alpha:1];
        self.icon = [UIImage imageNamed:@"icon_action_scale"];
        
        self.type = ScaleActionTypeTo;
        self.scale = CGSizeMake(1, 1);
        self.easingType = EasingTypeNone;
        self.easingMode = EasingModeIn;
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionIntervalScale* targetAction = (TActionIntervalScale*)target;
    targetAction.type = self.type;
    targetAction.scale = self.scale;
    targetAction.easingType = self.easingType;
    targetAction.easingMode = self.easingMode;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionIntervalScale"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        _type           = [TUtil parseIntXElement:[xml childNamed:@"Type"] default:ScaleActionTypeTo];
        _scale.width    = [TUtil parseFloatXElement:[xml childNamed:@"ScaleWidth"] default:1];
        _scale.height   = [TUtil parseFloatXElement:[xml childNamed:@"ScaleHeight"] default:1];
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
        
        run_startScale = target.scale;
        
        if (self.type == ScaleActionTypeTo)
            run_endScale = self.scale;
        else if (self.type == ScaleActionTypeBy)
            run_endScale = CGSizeMake(run_startScale.width * self.scale.width, run_startScale.height * self.scale.height);
        
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
        float width = [run_easingFunction easeByType:self.easingType mode:self.easingMode duration:self.duration time:elapsed start:run_startScale.width end:run_endScale.width];
        float height = [run_easingFunction easeByType:self.easingType mode:self.easingMode duration:self.duration time:elapsed start:run_startScale.height end:run_endScale.height];
        target.scale = CGSizeMake(width, height);
    }
    
    return [super step:delegate time:time];
}

@end
